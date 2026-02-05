import { getAuth } from "firebase-admin/auth";
import type { Context, Env } from "hono";


export const SigninHandler = async(c: Context<Env, 'auth/signin'>) => {

  const email = c.req.valid
  getAuth()
    .createUser({
      email: "",
      emailVerified: false,
      phoneNumber: "+111223123",
      password: "",
      displayName: "",
      disabled: false
    })
    .then((userRecord) => {
      return c.json({
        message: "Success, you were succesfully signed in",
        status: 200,
      })
    })
 
  

  // const 
}