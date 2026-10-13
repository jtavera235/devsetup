---
name: writing-test
description: Used when writing tests to validate code that was written. 
---

Tests should be packaged where each class tests a high-level concept where each individual method tests specific use-cases. 

When writing a test, try coupling together any related concepts that can be tested together.

EX:

DO 

```

testAccountCreation() {
  
  var account = createAccount();
  validateAccountEmail(account);
  validateAccountUsername(account);
}

```

DO NOT

```
testAccountCreationEmail() {
  
  var account = createAccount();
  validateAccountEmail(account);
}

testAccountCreationUsername() {
  
  var account = createAccount();
  validateAccountUsername(account);
}
```

There should be unit tests which are used to test specific tiny pieces of code. Unit tests can use mocks as needed.

Integration tests should be written and avoid mocking as much as possible. If unclear whether something should be mocked then ask instead of assuming.