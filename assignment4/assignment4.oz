%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  PROGRAMMING LANGUAGES - ASSIGNMENT 4  %
%  AUTHOR: Magnus Conrad Hyll            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

functor
import
    System
    Application
define



/*
TASK 1
*/
fun {GenerateOdd S E}
local StartOdd in
    if S mod 2 == 0 then StartOdd = S + 1
    else StartOdd = S end

    if StartOdd =< E then
        StartOdd|{GenerateOdd StartOdd+2 E}
    else
        nil
    end
end
end

{System.show {GenerateOdd ~3 10}}
{System.show {GenerateOdd 3 3}}
{System.show {GenerateOdd 2 2}}



/*
TASK 2
*/
fun {Product S}
    fun {ProductInner S A}
        case S of nil then
            A
        [] Head|Tail then
            {ProductInner Tail Head*A}
        end
    end
in
    {ProductInner S 1}
end

{System.show {Product [1 2 3 4]}}



/*
TASK 3
*/


{Application.exit 0}

end