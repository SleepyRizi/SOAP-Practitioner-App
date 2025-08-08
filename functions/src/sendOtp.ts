/* eslint-disable max-len */

import {onCall, HttpsError} from "firebase-functions/v2/https";
import nodemailer from "nodemailer";

/* ───── SMTP CONFIG (hard-coded) ───── */
const SMTP_HOST = "smtp.hostinger.com";
const SMTP_PORT = Number(587); // number, not literal type
const SMTP_USERNAME = "no-reply@entravoid.io";
const SMTP_PASSWORD = "PakistanLhr@786!";
const EMAIL_FROM = "no-reply@entravoid.io";

/* Single transporter reused across cold starts */
const transporter = nodemailer.createTransport({
  host: SMTP_HOST,
  port: SMTP_PORT,
  secure: SMTP_PORT === 465, // SSL only if port 465
  auth: {user: SMTP_USERNAME, pass: SMTP_PASSWORD},
  tls: {rejectUnauthorized: false},
});

/**
 * Build the HTML body for the OTP message.
 *
 * @param {string} code       Six-digit verification code.
 * @param {"signup"|"reset"} purpose  Why we’re sending the code.
 * @return {string} Complete HTML markup for the e-mail.
 */
function buildHtml(code:string, purpose:"signup"|"reset"):string {
  const title = purpose==="signup" ? "Verify e-mail" : "Reset password";
  const intro = purpose==="signup" ? "Thanks for joining us!" : "We received a password-reset request.";
  const action = purpose==="signup" ? "verify your e-mail address" : "reset your password";

  return `<!doctype html>
<html><head><meta charset="utf-8"/><title>${title}</title>
<style>
body{background:#f5f7fa;font-family:Arial;margin:0;padding:40px}
.box{background:#fff;border-radius:8px;max-width:600px;margin:auto;box-shadow:0 2px 8px rgba(0,0,0,.05)}
.header{background:#3F51B5;color:#fff;text-align:center;padding:24px}
.code{display:inline-block;background:#3F51B5;color:#fff;padding:14px 24px;border-radius:6px;font-size:28px;letter-spacing:6px}
.content{padding:32px 40px;color:#333;line-height:1.6;font-size:15px}
.footer{background:#f0f0f5;color:#888;font-size:12px;text-align:center;padding:20px}
</style></head><body>
<div class="box">
  <div class="header"><h1 style="margin:0">SoapNotes</h1></div>
  <div class="content">
    <p>${intro} Use the code below to ${action}.</p>
    <p style="text-align:center"><span class="code">${code}</span></p>
    <p>This code expires in <strong>10&nbsp;minutes</strong>.</p>
  </div>
  <div class="footer">&copy; ${new Date().getFullYear()} SoapNotes</div>
</div>
</body></html>`;
}

/* ───── Callable Function ───── */
export const sendOtpEmail = onCall(async (req)=>{
  const {email, code, purpose="signup"} = req.data as {
    email?:string; code?:string; purpose?:"signup"|"reset";
  };

  if (!email||!code) {
    throw new HttpsError("invalid-argument", "email & code are required.");
  }

  await transporter.sendMail({
    from: EMAIL_FROM,
    to: email,
    subject: purpose==="signup" ? "Verify your e-mail" : "Password reset code",
    html: buildHtml(code, purpose),
    text: `Your verification code is ${code}`,
  });

  return {status: "ok"};
});
