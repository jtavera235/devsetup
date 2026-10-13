---
name: writing-code
description: Used when writing any piece of code that is not scripting. 
---

Code must be clean, readable, and maintainable. 

Do NOT write any code comments. Only in the strict case when something is NOT obvious should
a code comment be left that can not be longer than 2 lines. Variable naming/method names should be clear enough to give enough context.

Validate first and then process. Make sure validation methods occur as early as possible. Do
not have validation methods return anything. Have them throw errors within the methods. Validations should have a Command/Object-level validation with sub-methods to validate specific functionality.

EX:
```
class AccountValidator {


  public void validate(Account account) {
    validateUsername(account.getUsername());
    validateEmail(account.getEmail());
  }

  private void validateUsername(String username) {
    // Validation logic here
  }

  private void validateEmail(String email) {
    // Validation logic here
  }
}
```


