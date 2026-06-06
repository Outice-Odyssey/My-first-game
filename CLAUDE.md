## Code Change Explanations (Always Required)

After every code modification, update, refactor, or generated implementation, you must provide an explanation of what changed.

### Explanation Format

1. **What Changed**
   - Summarize the specific code changes made.
   - Mention affected files, functions, classes, or components.

2. **Why It Changed**
   - Explain the purpose of the change.
   - Describe the problem being solved or the improvement being made.

3. **ELI5 (Explain Like I'm 5)**
   - Provide a simple, non-technical explanation.
   - Use analogies when helpful.
   - Assume the reader has little to no knowledge of the codebase.

4. **Impact**
   - Describe any behavioral changes.
   - Mention potential side effects, risks, or things to test.

### Example Structure

#### What Changed
- Added validation to `createUser()`.
- Prevented empty email addresses from being submitted.

#### Why It Changed
- The application could create invalid users when no email was provided.

#### ELI5
- Think of a signup form like a guest list. Before adding someone's name, we now make sure they actually wrote their name on the paper.

#### Impact
- Users must provide a valid email before an account can be created. 