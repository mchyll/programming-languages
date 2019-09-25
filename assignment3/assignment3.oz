%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  PROGRAMMING LANGUAGES - ASSIGNMENT 3  %
%  AUTHOR: Magnus Conrad Hyll            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

functor
import
    Application
    System
define

% Helper function which converts an Int to a Float, only if the given argument actually is an Int.
fun {IntToFloat I}
    if {Int.is I} then {Int.toFloat I}
    else I
    end
end



/* TASK 1 a) */
proc {QuadraticEquation A B C ?RealSol ?X1 ?X2}
    local
        % Ensure the arguments are floats
        Af = {IntToFloat A}
        Bf = {IntToFloat B}
        Cf = {IntToFloat C}

        % Calculate the expression inside the square root
        Df = Bf * Bf - 4.0 * Af * Cf
    in
        if Df < 0.0 then
            RealSol = false
        else
            RealSol = true
            X1 = (~Bf + {Float.sqrt Df}) / (2.0 * Af)
            X2 = (~Bf - {Float.sqrt Df}) / (2.0 * Af)
        end
    end
end

local X1 X2 RealSol in
    {QuadraticEquation 2 1 ~1 RealSol X1 X2}
    {System.showInfo "Values of X1, X2 and RealSol when A = 2, B = 1 and C = -1:"}
    {System.printInfo X1#" "}
    {System.printInfo X2#" "}
    {System.show RealSol}
end

% When A = 2, B = 1 and C = 2, RealSol will be false, and X1 and X2 will be unbound.

/*
TASK 1 b)
Procedural abstractions are useful because (including, but not limited to):
- They allow us to give a name to a well-defined "sub-task" of the program.
- They let us hide implementation details for these "sub-tasks" in the program.
  When calling the procedure, we only need to care about what it does, but not how it does it.
- For common tasks, we can just call the procedure multiple places instead of
  copy-pasting identical blocks of code.

TASK 1 c)
Procedures just execute statements without returning a value, while functions do return a value.
*/



/* TASK 2 */
fun {Sum List}
    case List of nil then
        0
    [] Head|Tail then
        Head + {Sum Tail}
    end
end

{System.showInfo {Sum [1 2 3 4]}}



/* TASK 3 a) and b) */
fun {RightFold List Op U}                % Line-by-line explanation:
    case List of nil then                % Pattern-match the list, start by checking if the list is nil.
        U                                % If the list is empty, i.e. nil, just return the neutral element.
    [] Head|Tail then                    % If the list has a head element and some rest elements,
        {Op Head {RightFold Tail Op U}}  % apply the operator on the head element and the result of the fold applied to the rest of the elements.
    end
end

{System.showInfo {RightFold X fun {$ X Y} X * Y end 1}}

{Application.exit 0}

end
