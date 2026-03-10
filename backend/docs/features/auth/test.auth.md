Now you can test the whole pipeline with curl:

```
curl -i -X POST http://localhost:3000/auth/dev/login \
  -H "Content-Type: application/json" \
  -d '{"userId":"test-user-123"}'
```

Copy the Set-Cookie header into subsequent requests or use -c/-b cookie jar:


```bash
curl -c cookies.txt -i -X POST http://localhost:3000/auth/dev/login \
-H "Content-Type: application/json" \
-d '{"userId":"test-user-123"}'

curl -b cookies.txt http://localhost:3000/me
```


### Instrucciones para frontend

-> Add all the packaged necessary for the FirebaseAuth
-> implement the email/password signup 
-> Implement the sign in calling Firebase sign-in
-> Get firebase ID token (required)
->-> store the id in a local variable and immediately send it to the backend

Backend contract:
	•	URL: POST {API_BASE_URL}/auth/firebase/login
	•	Body JSON: { "idToken": "<token>" }
	•	Backend sets cookie: Set-Cookie: session=...; HttpOnly; ...


	1.	Build URLRequest
	2.	Set JSON body
	3.	Use URLSession.shared
	4.	Ensure cookies are handled

code example: GPT generated

```swift
import Foundation

func backendLogin(idToken: String, apiBaseUrl: String) async throws {
  let url = URL(string: "\(apiBaseUrl)/auth/firebase/login")!
  var req = URLRequest(url: url)
  req.httpMethod = "POST"
  req.setValue("application/json", forHTTPHeaderField: "Content-Type")
  req.httpShouldHandleCookies = true

  let body = ["idToken": idToken]
  req.httpBody = try JSONSerialization.data(withJSONObject: body)

  let (data, resp) = try await URLSession.shared.data(for: req)

  guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
  guard (200..<300).contains(http.statusCode) else {
    let txt = String(data: data, encoding: .utf8) ?? ""
    throw NSError(domain: "Backend", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: txt])
  }

  // Cookie should now be stored in HTTPCookieStorage.shared automatically
}
```

->  Immediately verify backend cookie works (call protected route)

```swift
func backendMe(apiBaseUrl: String) async throws -> String {
  let url = URL(string: "\(apiBaseUrl)/me")!
  var req = URLRequest(url: url)
  req.httpMethod = "GET"
  req.httpShouldHandleCookies = true

  let (data, resp) = try await URLSession.shared.data(for: req)

  guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
  let txt = String(data: data, encoding: .utf8) ?? ""

  guard (200..<300).contains(http.statusCode) else {
    throw NSError(domain: "Backend", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: txt])
  }

  return txt
}
```

Logout flow

Steps:
	1.	Firebase sign-out
	2.	Backend cookie clear

```swift
import FirebaseAuth

func logout(apiBaseUrl: String) async throws {
  try Auth.auth().signOut()

  let url = URL(string: "\(apiBaseUrl)/auth/firebase/logout")!
  var req = URLRequest(url: url)
  req.httpMethod = "POST"
  req.httpShouldHandleCookies = true

  _ = try await URLSession.shared.data(for: req)
}
```