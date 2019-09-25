%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PROGRAMMING LANGUAGES - ASSIGNMENT 3 %
% AUTHOR: Magnus Conrad Hyll           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

functor
import
    Application
    System
define

% Helper function which converts an Int to a Float, only if the given argument actually is an Int.
fun {IntToFloat I}
    if {Int.is I} then
        {Int.toFloat I}
    else
        I
    end
end

% TASK 1 a)
proc {QuadraticEquation A B C ?RealSol ?X1 ?X2}
    local
        % Convert the arguments to floats
        Af = {IntToFloat A}
        Bf = {IntToFloat B}
        Cf = {IntToFloat C}
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

local X1 X2 R in
    {QuadraticEquation 2.0 1 ~1 R X1 X2}
    {System.show R}
    {System.showInfo X1}
    {System.showInfo X2}
end

{Application.exit 0}

end
