"use strict";

/**
 * Kootu phone-OTP backend.
 *
 * Why this exists: Firebase's client-side phone auth relies on Play Integrity,
 * which rejects unpublished / sideloaded builds ("app not Recognized by Play
 * Store") and falls back to a fragile reCAPTCHA web flow. Instead we own the
 * OTP: a code is generated here, delivered over MSG91's SMS gateway, verified
 * here, and on success we mint a Firebase **custom token**. The app signs in
 * with that token, so the rest of the app (Firestore rules keyed on
 * `request.auth.uid`, user docs, etc.) keeps working unchanged — only the SMS
 * layer changed.
 *
 * Security model:
 *  - Only a salted HMAC of the code is stored in Firestore (never the code).
 *  - `otps/{phone}` is denied to all clients by firestore.rules; only the
 *    Admin SDK (these functions) can read/write it.
 *  - Resend cooldown + max attempts + short TTL throttle brute force.
 *  - Secrets (MSG91 auth key, HMAC pepper) come from Functions secrets, never
 *    the repo.
 */

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const crypto = require("crypto");

admin.initializeApp();
const db = admin.firestore();

// Secrets — set with:
//   firebase functions:secrets:set MSG91_AUTHKEY
//   firebase functions:secrets:set OTP_PEPPER
const MSG91_AUTHKEY = defineSecret("MSG91_AUTHKEY");
const OTP_PEPPER = defineSecret("OTP_PEPPER");

// MSG91 sending config. In India these must be DLT-approved values from your
// MSG91 dashboard. Override via env (functions config) or edit here.
const MSG91_SENDER = process.env.MSG91_SENDER || "KOOTUA";
const MSG91_TEMPLATE_ID = process.env.MSG91_TEMPLATE_ID || "REPLACE_WITH_DLT_TEMPLATE_ID";

const OTP_TTL_MS = 5 * 60 * 1000; // code valid for 5 minutes
const MAX_ATTEMPTS = 5; // wrong-code tries before the code is burned
const RESEND_COOLDOWN_MS = 30 * 1000; // min gap between sends to one number
const REGION = "us-central1"; // must match FirebaseFunctions.instance on the client

function hmac(phone, code, pepper) {
  return crypto.createHmac("sha256", pepper).update(`${phone}:${code}`).digest("hex");
}

function normalizePhone(raw) {
  const p = String(raw || "").trim();
  // E.164: leading + and 8–15 digits.
  if (!/^\+\d{8,15}$/.test(p)) {
    throw new HttpsError("invalid-argument", "Enter a valid phone number.");
  }
  return p;
}

exports.sendOtp = onCall(
  { secrets: [MSG91_AUTHKEY, OTP_PEPPER], region: REGION },
  async (req) => {
    const phone = normalizePhone(req.data && req.data.phone);
    const ref = db.collection("otps").doc(phone);
    const now = Date.now();

    const snap = await ref.get();
    if (snap.exists && now - (snap.data().createdAt || 0) < RESEND_COOLDOWN_MS) {
      throw new HttpsError(
        "resource-exhausted",
        "Please wait a moment before requesting another code."
      );
    }

    const code = String(Math.floor(100000 + Math.random() * 900000)); // 6 digits
    await ref.set({
      codeHash: hmac(phone, code, OTP_PEPPER.value()),
      expiresAt: now + OTP_TTL_MS,
      attempts: 0,
      createdAt: now,
    });

    // Deliver via MSG91 Flow API. Node 20 provides a global fetch.
    let resp;
    try {
      resp = await fetch("https://control.msg91.com/api/v5/flow/", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          authkey: MSG91_AUTHKEY.value(),
        },
        body: JSON.stringify({
          template_id: MSG91_TEMPLATE_ID,
          sender: MSG91_SENDER,
          short_url: "0",
          recipients: [{ mobiles: phone.replace("+", ""), otp: code }],
        }),
      });
    } catch (e) {
      logger.error("MSG91 request threw", e);
      throw new HttpsError("internal", "Could not send the verification SMS.");
    }
    if (!resp.ok) {
      const text = await resp.text().catch(() => "");
      logger.error("MSG91 send failed", { status: resp.status, body: text });
      throw new HttpsError("internal", "Could not send the verification SMS.");
    }

    return { ok: true };
  }
);

exports.verifyOtp = onCall(
  { secrets: [OTP_PEPPER], region: REGION },
  async (req) => {
    const phone = normalizePhone(req.data && req.data.phone);
    const code = String((req.data && req.data.code) || "").trim();
    if (!/^\d{6}$/.test(code)) {
      throw new HttpsError("invalid-argument", "Enter the 6-digit code.");
    }

    const ref = db.collection("otps").doc(phone);
    const snap = await ref.get();
    if (!snap.exists) {
      throw new HttpsError("not-found", "No code was requested for this number.");
    }
    const data = snap.data();

    if (Date.now() > data.expiresAt) {
      await ref.delete();
      throw new HttpsError("deadline-exceeded", "That code expired. Request a new one.");
    }
    if ((data.attempts || 0) >= MAX_ATTEMPTS) {
      await ref.delete();
      throw new HttpsError("resource-exhausted", "Too many attempts. Request a new code.");
    }
    if (hmac(phone, code, OTP_PEPPER.value()) !== data.codeHash) {
      await ref.update({ attempts: admin.firestore.FieldValue.increment(1) });
      throw new HttpsError("permission-denied", "Incorrect code. Please try again.");
    }

    // Success — burn the code and mint a Firebase session keyed on the number.
    await ref.delete();
    const uid = phone.replace(/[^\d]/g, ""); // e.g. +919042512878 -> 919042512878
    const token = await admin.auth().createCustomToken(uid, { phone_number: phone });
    return { token };
  }
);
