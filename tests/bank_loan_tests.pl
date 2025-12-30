:- begin_tests(bank_loan).

% load the KB using a path relative to this test file so CI and local runs work
:- consult('../bank_loan.pl').

test(c1_approve) :-
    assertion(decide_loan(c1, approve)).

test(c2_reject) :-
    assertion(decide_loan(c2, reject)).

test(c3_conditional) :-
    assertion(decide_loan(c3, conditional)).

test(c3_explanation) :-
    explain_decision(c3, Decision, Reasons),
    assertion(Decision == conditional),
    % expect at least these supporting reasons for c3
    assertion(member(borderline_credit_score, Reasons)),
    assertion(member(self_employed, Reasons)).

test(c4_reject) :-
    assertion(decide_loan(c4, reject)).

test(c5_reject) :-
    assertion(decide_loan(c5, reject)).

test(c5_risk_high) :-
    assertion(risk_level(c5, high)).

test(c6_reject) :-
    assertion(decide_loan(c6, reject)).

test(c6_explanation_too_young) :-
    explain_decision(c6, Decision, Reasons),
    assertion(Decision == reject),
    assertion(member(too_young, Reasons)).

% Boundary tests
test(boundary_cs_700_conditional) :-
    % credit score = 700 should be considered conditional (600..700)
    assertion(decide_loan(b1, conditional)),
        assertion(decide_loan(b1, conditional)).

test(boundary_cs_600_conditional) :-
    % credit score = 600 should be conditional (lower borderline)
    assertion(decide_loan(b2, conditional)),
        assertion(decide_loan(b2, conditional)).

test(boundary_dti_30_unknown_for_highscore) :-
    % DTI = 30 with credit score >700 does not satisfy approve (needs DTI <30) and not conditional (score >700)
    assertion(decide_loan(b3, unknown)),
        assertion(decide_loan(b3, unknown)).

test(boundary_dti_40_unknown_for_highscore) :-
    % DTI = 40 with credit score >700 should not be rejected (reject >40) and not conditional (score >700) -> unknown
    assertion(decide_loan(b4, unknown)),
        assertion(decide_loan(b4, unknown)).

test(boundary_loan_50pct_approve) :-
    % Loan amount exactly 50% of income should be allowed (<= 50%) and with other approvals should approve
    assertion(decide_loan(b5, approve)),
        assertion(decide_loan(b5, approve)).

:- end_tests(bank_loan).

:- if(current_prolog_flag(argv, _)).
:- endif.
