%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  PROGRAMMING LANGUAGES - ASSIGNMENT 6  %
%  AUTHOR: Magnus Conrad Hyll            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

functor
import
    System
    Application
    Space
define

% Solver functions from attachment to lecture 11
\insert solve.oz

% The following procedure and RelationClass is taken from CTMCP p. 659

proc {Choose ?X Ys}
    choice Ys = X|_
    [] Yr in Ys = _|Yr {Choose X Yr} end
end

class RelationClass
    attr d

    meth init
        d := {NewDictionary}
    end

    % Adds the list of tuples Is to the relation. Assertall can only be done outside a relational program.
    meth assertall(Is)
        for I in Is do {self assert(I)} end
    end

    % Adds the tuple I to the relation. Assert can only be done outside a relational program.
    meth assert(I)
        if {IsDet I.1} then
            Is = {Dictionary.condGet @d I.1 nil} in
            {Dictionary.put @d I.1 {Append Is [I]}}
        else
            raise databaseError(nonground(I)) end
        end
    end

    % Binds I to one of the tuples in the relation. I can be any partial
    % value. If more than one tuple is compatible with I, then search can enumerate
    % all of them. Query can only be done inside a relational program.
    meth query(I)
        if {IsDet I} andthen {IsDet I.1} then
            {Choose I {Dictionary.condGet @d I.1 nil}}
        else
            {Choose I {Flatten {Dictionary.items @d}}}
        end
    end
end



% This relation contains the cabins
Cabins = {New RelationClass init}
{Cabins assertall([
    cabin(1) cabin(2) cabin(3)
    cabin(4) cabin(5) cabin(6)
    cabin(7) cabin(8) cabin(9)
])}

% This relation contains all edges, or distances, between cabins
Distances = {New RelationClass init}
{Distances assertall([
    distance(1 2 9 true)
    distance(1 4 3 true)
    distance(2 3 9 true)
    distance(2 5 3 true)
    distance(3 4 1 true)
    distance(4 5 2 true)
    distance(4 2 3 true)
    distance(5 6 1 true)
    distance(6 7 5 true)
    distance(7 3 6 true)
])}

% Queries the cabin relation for a cabin C
proc {CabinP C} {Cabins query(cabin(C))} end

% Queries the distance relation for an edge from cabin A to B of distance Dist
proc {DistanceP A B ?Dist} {Distances query(distance(A B Dist true))} end


% Defines a relation which is true if Path is a path from cabin A to B of distance Dist
proc {PathP ?A ?B ?Path ?Dist}
    {CabinP A}
    {PathPIterator A B [A] Path 0 Dist}
end

% Iterator used in PathP, with extra arguments for path found so far and current distance
proc {PathPIterator ?A ?B Trace ?Path AccumulatedDist ?Dist}
    choice
        % If A=B doesn't fail, we've reached the destination cabin and have found a path
        % Bind result to Path and Dist variables
        A = B
        Path = {Reverse Trace}
        Dist = AccumulatedDist

    [] C EdgeDist in
        % Find a cabin C which we can travel via to reach the destination cabin B
        % Make sure C is not already visited
        {DistanceP A C EdgeDist}
        {Member C Trace} = false
        {PathPIterator C B C|Trace Path EdgeDist+AccumulatedDist Dist}
    end
end


% TASK 1 a)
% Non-deterministic function which finds plans with paths from Cabin1 to Cabin2
% Returns a tuple Distance#Path where Distance is a number and Path is a list of cabins
fun {Plan Cabin1 Cabin2}
    Distance Path
in
    {PathP Cabin1 Cabin2 Path Distance}
    Distance#Path
end

% Helper function which instantiate calls to Plan with Cabin1 and Cabin2
fun {PlanTrip Cabin1 Cabin2}
    fun {$} {Plan Cabin1 Cabin2} end
end


% TASK 1 b)
% Recursively checks all solutions to Plan and returns the plan with the minimum distance
fun {BestPlan Cabin1 Cabin2}
    fun {BestPlanIterator Plans BestSoFar}
        case Plans of nil then
            BestSoFar

        [] Plan|Rest then
        Dist#_ = Plan
        BestDist#_ = BestSoFar in
        % Compare distance of this plan and current best plan
            if Dist < BestDist then
                {BestPlanIterator Rest Plan}
            else
                {BestPlanIterator Rest BestSoFar}
            end
        end
    end
    % Find all possible plans, that is, all solutions to PlanTrip
    AllPlans = {SolveAll {PlanTrip Cabin1 Cabin2}}
in
    % Start the iterator with the first plan as the current best
    {BestPlanIterator AllPlans AllPlans.1}
end


{System.showInfo "All plans with paths from cabin 1 to 3:"}
{System.show {SolveAll {PlanTrip 1 3}}}

{System.showInfo "\nThe best plan with a path from cabin 1 to 3:"}
{System.show {BestPlan 1 3}}



{Application.exit 0}

end
