% These predicates are declared as facts in this file and may be seen as discontiguous
:- discontiguous credit_score/2.
:- discontiguous income/2.
:- discontiguous dti/2.
:- discontiguous employed/1.
:- discontiguous self_employed/1.
:- discontiguous unemployed/1.
:- discontiguous age/2.
:- discontiguous loan_amount/2.

% ---------------------------
% Thresholds / configuration
% ---------------------------

min_credit_score_for_approval(700).
min_income_for_approval(50000).    % USD
max_dti_for_approval(30).          % percent
max_dti_for_conditional(40).      % percent
min_age(21).
max_loan_percent_of_income(0.5).   % 50% of annual income

% ---------------------------
% Attribute predicates (facts)
% ---------------------------
% These are intended to be provided per applicant. Examples are included below.

% Examples (from README) — uncomment or load file as-is to use these sample facts.
credit_score(c1, 750). income(c1, 60000). dti(c1, 25). employed(c1). age(c1, 30). loan_amount(c1, 20000).
credit_score(c2, 550). income(c2, 40000). dti(c2, 35). employed(c2). age(c2, 25). loan_amount(c2, 15000).
credit_score(c3, 650). income(c3, 45000). dti(c3, 35). self_employed(c3). age(c3, 28). loan_amount(c3, 20000).
credit_score(c4, 720). income(c4, 30000). dti(c4, 20). unemployed(c4). age(c4, 22). loan_amount(c4, 10000).
credit_score(c5, 680). income(c5, 55000). dti(c5, 45). employed(c5). age(c5, 35). loan_amount(c5, 25000).
credit_score(c6, 710). income(c6, 52000). dti(c6, 28). employed(c6). age(c6, 19). loan_amount(c6, 20000).

% Employment helper: unify with one of the statuses
employment_status(ID, employed) :- employed(ID).
employment_status(ID, self_employed) :- self_employed(ID).
employment_status(ID, unemployed) :- unemployed(ID).

% ---------------------------
% Core decision rules
% ---------------------------

% Approve if: credit score > min, income > min, dti < max, employed or self-employed,
% age >= min, loan_amount =< max percent of income.
approve_loan(ID) :-
    credit_score(ID, Score),
    min_credit_score_for_approval(MinScore), Score > MinScore,
    income(ID, Inc), min_income_for_approval(MinInc), Inc > MinInc,
    dti(ID, DTI), max_dti_for_approval(MaxDTI), DTI < MaxDTI,
    (employed(ID); self_employed(ID)),
    age(ID, Age), min_age(MinAge), Age >= MinAge,
    loan_amount(ID, Amt),
    max_loan_percent_of_income(Pct),
    MaxAmt is Inc * Pct, Amt =< MaxAmt.

% Reject if any strong rejecting condition holds
reject_loan(ID) :-
    credit_score(ID, Score), Score < 600.
reject_loan(ID) :- unemployed(ID).
reject_loan(ID) :- dti(ID, DTI), DTI > 40.
reject_loan(ID) :- age(ID, Age), min_age(MinAge), Age < MinAge.

% Conditional approval: not approved, not rejected, but in borderline ranges
conditional_approve(ID) :-
    \+ approve_loan(ID),
    \+ reject_loan(ID),
    credit_score(ID, Score), Score >= 600, Score =< 700,
    dti(ID, DTI), max_dti_for_conditional(MaxC), DTI =< MaxC.

% decide_loan/2: choose a single decision atom: approve | reject | conditional
decide_loan(ID, approve) :- approve_loan(ID), !.
decide_loan(ID, reject) :- reject_loan(ID), !.
decide_loan(ID, conditional) :- conditional_approve(ID), !.
decide_loan(ID, unknown) :- % insufficient data or doesn't match any rule
    \+ approve_loan(ID), \+ reject_loan(ID), \+ conditional_approve(ID).

% ---------------------------
% Explanations and reasons
% ---------------------------

% gather_reasons/2 collects notable positive and negative reasons as a list of atoms
gather_reasons(ID, Reasons) :-
    findall(R, reason_for(ID, R), Reasons0),
    (Reasons0 = [] -> Reasons = [no_data_provided] ; Reasons = Reasons0).

% reason_for/2 defines human-readable short reasons (atoms) for findings
reason_for(ID, high_credit_score) :- credit_score(ID, Score), min_credit_score_for_approval(Min), Score > Min.
reason_for(ID, low_credit_score) :- credit_score(ID, Score), Score < 600.
reason_for(ID, borderline_credit_score) :- credit_score(ID, Score), Score >= 600, Score =< 700.

reason_for(ID, sufficient_income) :- income(ID, Inc), min_income_for_approval(Min), Inc > Min.
reason_for(ID, low_income) :- income(ID, Inc), min_income_for_approval(Min), Inc =< Min.

reason_for(ID, low_dti) :- dti(ID, D), max_dti_for_approval(Max), D < Max.
reason_for(ID, high_dti) :- dti(ID, D), D > 40.
reason_for(ID, borderline_dti) :- dti(ID, D), max_dti_for_approval(Max), D >= Max, D =< 40.

reason_for(ID, employed) :- employed(ID).
reason_for(ID, self_employed) :- self_employed(ID).
reason_for(ID, unemployed) :- unemployed(ID).

reason_for(ID, too_young) :- age(ID, A), min_age(Min), A < Min.
reason_for(ID, adult) :- age(ID, A), min_age(Min), A >= Min.

reason_for(ID, loan_within_limit) :- loan_amount(ID, Amt), income(ID, Inc), max_loan_percent_of_income(Pct), Limit is Inc * Pct, Amt =< Limit.
reason_for(ID, loan_exceeds_limit) :- loan_amount(ID, Amt), income(ID, Inc), max_loan_percent_of_income(Pct), Limit is Inc * Pct, Amt > Limit.

% explain_decision(ID, Decision, Reasons) returns Decision and a list Reasons describing supporting facts
explain_decision(ID, Decision, Reasons) :-
    decide_loan(ID, Decision),
    gather_reasons(ID, Reasons).

% ---------------------------
% Risk classification
% ---------------------------

% risk_level/2: low, medium, high — simple heuristic
risk_level(ID, low) :- credit_score(ID, S), S > 700, dti(ID, D), D < 30.
risk_level(ID, medium) :- credit_score(ID, S), S >= 600, S =< 700, dti(ID, D), D =< 40.
risk_level(ID, high) :- credit_score(ID, S), S < 600.
risk_level(ID, high) :- dti(ID, D), D > 40.

% ---------------------------
% Convenience: run sample tests and collect results
% ---------------------------

% sample_results(-List) collects pairs ID-Decision for the sample facts present in this file
sample_results(Results) :-
    setof(ID-Decision, (applicant_id(ID), decide_loan(ID, Decision)), Results), !.
sample_results([]).

% applicant_id/1 enumerates sample applicants present in this file
applicant_id(ID) :- credit_score(ID, _).

% pretty_print_results/0 prints sample results in readable form (works in SWI-Prolog)
pretty_print_results :-
    sample_results(Results),
    forall(member(ID-Decision, Results), (format('~w -> ~w~n', [ID, Decision]))).

% ---------------------------
% End of file
% ---------------------------
