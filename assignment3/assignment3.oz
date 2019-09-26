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
    else I end
end



/*
TASK 1 a)
*/
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
    {System.showInfo "TASK 1 a):"}
    {System.showInfo "Result of QuadraticEquation when A = 2, B = 1 and C = -1:"}
    {System.printInfo "X1 = "#X1#", X2 = "#X2#", RealSol = "}
    {System.show RealSol}
    {System.showInfo "When A = 2, B = 1 and C = 2, RealSol will be false, and X1 and X2 will be unbound.\n"}
end

/*
TASK 1 b)
Procedural abstractions are useful because (including, but not limited to):
- They allow us to give a name to a well-defined "sub-task" of the program.
- They let us hide implementation details of these "sub-tasks" in the program.
  When calling the procedure, we only need to care about what it does, but not how it does it.
- For common tasks, we can just call the procedure multiple places instead of
  copy-pasting identical blocks of code.

TASK 1 c)
Procedures just execute statements without returning a value, while functions do return a value.
*/



/*
TASK 2
*/
fun {Sum List}
    case List of nil then
        0
    [] Head|Tail then
        Head + {Sum Tail}
    end
end

{System.showInfo "TASK 2:"}
{System.showInfo "{Sum [1 2 3 4]}"}
{System.showInfo {Sum [1 2 3 4]}}
{System.showInfo ""}



/*
TASK 3 a) and b)
*/                                       % Line-by-line explanation:
fun {RightFold List Op U}                % The RightFold function takes a List, an operator function Op, and a neutral element U.
    case List of nil then                % Pattern-match the list, start by checking if the list is nil.
        U                                % If the list is empty, i.e. nil, just return the neutral element.
    [] Head|Tail then                    % If the list has a head element and some rest elements,
        {Op Head {RightFold Tail Op U}}  % apply the operator on the head element and the result of the fold applied to the rest of the elements.
    end
end

{System.showInfo "TASK 3 a):"}
{System.showInfo "{RightFold [1 2 3 4] fun {$ X Y} X * Y end 1}"}
{System.showInfo {RightFold [1 2 3 4] fun {$ X Y} X * Y end 1}}
{System.showInfo ""}



/*
TASK 3 c)
I named the functions FoldLength and FoldSum instead, to avoid a
naming conflict with the Sum function I implemented in task 2.
*/
fun {FoldLength List}
    {RightFold List fun {$ X Y} 1 + Y end 0}
end

fun {FoldSum List}
    {RightFold List fun {$ X Y} X + Y end 0}
end

{System.showInfo "TASK 3 c):"}
{System.showInfo "{FoldLength [1 2 3 4]}"}
{System.showInfo {FoldLength [1 2 3 4]}}
{System.showInfo "{FoldSum [1 2 3 4]}"}
{System.showInfo {FoldSum [1 2 3 4]}}
{System.showInfo ""}

/*
TASK 3 d)
A left fold would give the same result for Sum.
Given a list of elements e1, e2, e3 and e4, right fold would yield a summation equivalent to:
    (e1 + (e2 + (e3 + (e4 + 0))))
Left fold would yield the following summation:
    ((((0 + e1) + e2) + e3) + e4)
These give the same result, because addition is associative.

Left fold for Length would give wrong results, unless we change the operator {Op X Y} from 1+Y to X+1.

For subtraction, left fold and right fold would yield different results, as subtraction is non-associative.
Right fold subtraction would give:
    (e1 - (e2 - (e3 - (e4 - 0))))
This is not equivalent to left fold subtraction:
    ((((0 - e1) - e2) - e3) - e4)



TASK 3 e)
When using RightFold to implement the product of list elements, U should be 1:
    (e1 * (e2 * (e3 * (e4 * 1))))
This is because the multiplicative identity is 1.
If we'd use 0, the product of the list would always return 0, since x * 0 = 0.
*/



/*
TASK 4
*/
fun {Quadratic A B C}
    fun {$ X}
        A*X*X + B*X + C
    end
end

{System.showInfo "TASK 4:"}
{System.showInfo "{{Quadratic 3 2 1} 2}"}
{System.show {{Quadratic 3 2 1} 2}}
{System.showInfo ""}



/*
TASK 5 a)
*/
fun {LazyNumberGenerator StartValue}
    fun {NextGenerator}
        {LazyNumberGenerator StartValue+1}
    end
in
    StartValue|NextGenerator
end

{System.showInfo "TASK 5 a):"}
{System.showInfo "{LazyNumberGenerator 0}.1"}
{System.show {LazyNumberGenerator 0}.1}
{System.showInfo "{{LazyNumberGenerator 0}.2}.1"}
{System.show {{LazyNumberGenerator 0}.2}.1}
{System.showInfo "{{{{{{LazyNumberGenerator 0}.2}.2}.2}.2}.2}.1"}
{System.show {{{{{{LazyNumberGenerator 0}.2}.2}.2}.2}.2}.1}
{System.showInfo ""}

/*
TASK 5 b)
The LazyNumberGenerator takes a starting value as an argument. Inside the LazyNumberGenerator I define an inner function,
the NextGenerator. The LazyNumberGenerator then returns a list with the current StartValue and the NextGenerator function
as its elements. When NextGenerator eventually is called, it calls the LazyNumberGenerator anew with a starting value equal
to the current StartValue plus 1. The process starts over again, and we can build an infinite list by keeping on calling the
NextGenerators and accessing the first element of the returned lists.

A limitation of this might be that we need to explicitly call the NextGenerator function to generate the next number. A better
solution might have allowed us to just access the second elements of the lists to keep generating numbers, like so:
    {BetterLazyNumberGenerator 0}.2.2.2.2.2.1  =  5
This would have made it easier to use the number generator in pattern matching, etc.
*/



/*
TASK 6 a)
No, the Sum function from task 2 is not tail recursive. The following implementation is.

To change it into a tail recursive function, I put the code from Sum (the case-of block) into an inner function
which takes a list and an accumulator value as arguments. I modified the nil-case to return the accumulator instead of 0.
Instead of adding the current Head element to the result of a recursive call and returning that, I changed it to
add the Head element to the Accumulator value before the recursive call is made for the rest of the elements (the
addition is done before the recursive function call, even though they're on the same line).
This makes the recursive call the last statement of the function, without needing to "wait" for the recursive
call to complete and then adding the Head element, and thus makes it tail recursive.
To start the recursion, I call the inner function with the whole list and an initial accumulator value of 0.
*/
fun {TailRecursiveSum List}
    fun {Iterate List Accumulator}
        case List of nil then
            Accumulator
        [] Head|Tail then
            {Iterate Tail Accumulator+Head}
        end
    end
in
    {Iterate List 0}
end

{System.showInfo "TASK 6 a):"}
{System.showInfo "{TailRecursiveSum [1 2 3 4]}"}
{System.show {TailRecursiveSum [1 2 3 4]}}

/*
TASK 6 b)
Tail recursion allows for Last call optimization, where a function whose last statement is a recursive call to itself
(a tail-recursive function) is optimized into a kind of "loop", instead of having to go back though all the stacked call
frames like in ordinary recursion.
In Oz, last call optimization is automatically applied to tail recursive functions. This lets us avoid growing the semantic
stack for each recursive call, and instead keeps it in constant size during the computation.

TASK 6 c)
No, not necessarily. The language interpreter/compiler still needs to do Last call optimization
for us to benefit from tail recursion. For instance, Python allows recursion, but the Python interpreter
does not optimize tail tail recursions.
*/

{Application.exit 0}

end
