/* eslint-disable object-curly-spacing */

// functions/src/index.ts
import {setGlobalOptions} from "firebase-functions";

// ↓  GLOBAL RUNTIME OPTIONS  ↓
setGlobalOptions({maxInstances: 10});

/**
 * Re‑export each function defined in its own module so that
 * Firebase can discover and deploy them.
 *
 * If you add more functions later (e.g. sendAdminAlert, helloWorld),
 * create a file in src/ for each and add another export line here:
 *   export { sendAdminAlert } from "./sendAdminAlert";
 */
export {forceResetPassword} from "./resetPassword";
export {sendOtpEmail} from "./sendOtp"; // ← NEW
