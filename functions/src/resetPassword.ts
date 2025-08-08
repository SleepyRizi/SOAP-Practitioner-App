// functions/src/resetPassword.ts
import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

admin.initializeApp();

/**
 * Callable: forceResetPassword
 * Input: { email: string, newPassword: string }
 */
export const forceResetPassword = onCall(async (request) => {
  const {email, newPassword} = request.data as {
    email?: string;
    newPassword?: string;
  };

  if (!email || !newPassword) {
    throw new HttpsError(
      "invalid-argument",
      "Both email and newPassword are required."
    );
  }

  const user = await admin.auth().getUserByEmail(email);
  await admin.auth().updateUser(user.uid, {password: newPassword});

  return {status: "ok"};
});
