# Bank Loan Approval Expert System

[![Prolog tests](https://github.com/wende12github/Bank-Loan-Approval-Expert-System/actions/workflows/prolog-tests.yml/badge.svg)](https://github.com/wende12github/Bank-Loan-Approval-Expert-System/actions/workflows/prolog-tests.yml)

A small, explainable expert system implemented in Prolog that models a bank's personal loan decision logic. This repository contains a knowledge base and inference rules for classifying loan applications as Approved, Rejected, or Conditionally Approved. The system is intentionally simple and designed for teaching, experimentation, and extension.

Contents
- `bank_loan.pl` — Prolog knowledge base and rules implementing the decision logic, explanations, and simple risk classification.
- `LICENSE` — Project license.

Overview
--------
This project demonstrates a rule-based expert system for personal loan approval. It encodes common banking heuristics as Prolog facts and rules and supports:

- Clear decision outcomes: `approve` | `reject` | `conditional` | `unknown`.
- Short explanations describing supporting or rejecting facts.
- A simple risk classification (low/medium/high).
- Sample applicant facts to test the rules (included in `bank_loan.pl`).

Decision Criteria (implemented)
-------------------------------
The decision rules follow the simplified policy described below (these values are configurable in `bank_loan.pl`):

- Approve when all of the following hold:
  - Credit score > 700
  - Annual income > $50,000
  - Debt-to-Income ratio (DTI) < 30%
  - Employment: employed or self-employed
  - Age >= 21
  - Requested loan amount <= 50% of annual income

- Reject if any strong reject condition holds:
  - Credit score < 600
  - Applicant is unemployed
  - DTI > 40%
  - Age < 21

- Conditional approval (borderline cases):
  - Credit score in 600..700 (inclusive) and DTI between 30% and 40% (<= 40%)
  - Not already matched by explicit approve or reject rules

These thresholds are defined near the top of `bank_loan.pl` so you can tune them for experimentation.

What is in `bank_loan.pl`
-------------------------
Key predicates implemented:

- `approve_loan(ID)` — true when the applicant satisfies the approval rule.
- `reject_loan(ID)` — true when any rejection rule applies.
- `conditional_approve(ID)` — true for borderline, conditional cases.
- `decide_loan(ID, Decision)` — returns one of `approve`, `reject`, `conditional`, or `unknown`.
- `explain_decision(ID, Decision, Reasons)` — returns concise reasons (list of atoms) supporting the decision.
- `risk_level(ID, Level)` — returns `low`, `medium`, or `high` according to a simple heuristic.
- Sample applicant facts (c1..c6) — these match the examples used in the project report and allow quick testing.

Quick start (SWI-Prolog)
-------------------------
Prerequisites

- SWI-Prolog (tested with SWI-Prolog; other Prolog systems may work but adjust paths/commands accordingly).

Install on Debian/Ubuntu:

```bash
sudo apt update
sudo apt install swi-prolog
```

Load and query

1. Launch SWI-Prolog in the repository root (or specify path when loading):

```prolog
?- ["/workspaces/Bank-Loan-Approval-Expert-System/bank_loan.pl"].
```

2. Ask for a decision for a sample applicant (e.g. `c1`):

```prolog
?- decide_loan(c1, Decision).
Decision = approve.

?- explain_decision(c1, Decision, Reasons).
Decision = approve,
Reasons = [high_credit_score, sufficient_income, low_dti, employed, adult, loan_within_limit].

?- risk_level(c1, Level).
Level = low.
```

3. Print all sample results:

```prolog
?- pretty_print_results.
c1 -> approve
c2 -> reject
c3 -> conditional
c4 -> reject
c5 -> reject
c6 -> reject
```

Notes about data and missing attributes
-------------------------------------
- The system relies on facts for each applicant (predicates like `credit_score/2`, `income/2`, `dti/2`, `employed/1`, `age/2`, `loan_amount/2`). If an applicant lacks necessary facts, the result may be `unknown` and explanations may list `no_data_provided`.

Extending the system
---------------------
- Add new predicates for collateral, co-signer, or other loan types (home, business) and extend `decide_loan/2` with specialized rules.
- Replace deterministic thresholds with probabilistic or fuzzy rules for uncertainty handling.
- Integrate with a database or CSV import routine to evaluate many applicants in batch.

Testing suggestions
-------------------
- Add unit tests using SWI-Prolog's `plunit` framework to automatically verify the 6 sample cases and boundary conditions.
- Example test workflow (conceptual):

  1. Create a `tests/` directory with a `bank_loan_tests.pl` file that loads `bank_loan.pl` and defines test cases.
  2. Run tests with:

```prolog
?- run_tests.
```

Security and limitations
-------------------------
- This project is a teaching/example system and should not be used for production loan decisions. It omits regulatory, legal, and market factors.
- No personal data is included. If you adapt this for real data, follow privacy and security best practices.

License
-------
See `LICENSE` in the repository root for license terms.

Contact / Next steps
--------------------
If you'd like, I can add:

- `plunit` tests for the sample cases.
- A short script to bulk-evaluate CSV data and emit results.
- A small web UI demonstrating interactive queries.

Open issues or feature requests are welcome; tell me what you'd like to add next.

---
Generated and polished to make the project easier to understand and run. For details of the rules and sample facts, open `bank_loan.pl`.
