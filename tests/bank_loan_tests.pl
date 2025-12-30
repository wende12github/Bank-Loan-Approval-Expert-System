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

:- end_tests(bank_loan).

:- if(current_prolog_flag(argv, _)).
:- endif.
