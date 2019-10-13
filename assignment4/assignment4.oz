%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  PROGRAMMING LANGUAGES - ASSIGNMENT 4  %
%  AUTHOR: Magnus Conrad Hyll            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

functor
import
    System
    Application
    OS
define



/*
TASK 1
*/
fun {GenerateOdd S E}
StartOdd in
    if S mod 2 == 0 then StartOdd = S + 1
    else StartOdd = S end

    if StartOdd =< E then
        StartOdd|{GenerateOdd StartOdd+2 E}
    else
        nil
    end
end

{System.showInfo "TASK 1:"}
{System.showInfo "{GenerateOdd ~3 10}"}
{System.show {GenerateOdd ~3 10}}
{System.showInfo "{GenerateOdd 3 3}"}
{System.show {GenerateOdd 3 3}}
{System.showInfo "{GenerateOdd 2 2}"}
{System.show {GenerateOdd 2 2}}
{System.showInfo ""}



/*
TASK 2
*/
fun {Product S}
    case S of nil then
        1
    [] Head|Tail then
        Head * {Product Tail}
    end
end

{System.showInfo "TASK 2:"}
{System.showInfo "{Product [1 2 3 4]}"}
{System.show {Product [1 2 3 4]}}
{System.showInfo ""}



/*
TASK 3
The first three digits of the output are 100.
The benefit of running on two separate threads is that Product can start multiplying numbers from
the stream before all have been generated, while GenerateOdd can keep on generating new numbers concurrently.
*/
{System.showInfo "TASK 3:"}
local L P in
    thread L = {GenerateOdd 0 1000} end
    thread P = {Product L} end
    {System.showInfo P}
end
{System.showInfo ""}



/*
TASK 4
The throughput of this lazy function is reduced compared to the eager version. This is because
the lazy version only generates odd numbers on demand, and each time the consumer requests a
number it has to wait while it's calculated. In the eager version all numbers have been generated
ahead of time, and the consumer can get it right away.
The resource usage is reduced with the lazy generator, as it only needs to generate numbers and
hold them in memory when they are actually needed. The eager version generates all numbers at once,
meaning a lot more elements has to be held in memory at the same time.
*/
fun lazy {LazyGenerateOdd S E}
StartOdd in
    if S mod 2 == 0 then StartOdd = S + 1
    else StartOdd = S end

    if StartOdd =< E then
        StartOdd|{GenerateOdd StartOdd+2 E}
    else
        nil
    end
end

{System.showInfo "TASK 4:"}
{System.showInfo "{LazyGenerateOdd 0 1000}"}
{System.show {LazyGenerateOdd 0 1000}}
{System.showInfo ""}



/*
Helper function given in the assignment for generating random numbers
*/
fun {RandomInt Min Max}
    X = {OS.rand}
    MinOS
    MaxOS
in
    {OS.randLimits ?MinOS ?MaxOS}
    Min + X*(Max - Min) div (MaxOS - MinOS)
end



/*
TASK 5 a)
*/
fun lazy {HammerFactory}
    {Delay 1000}
    if {RandomInt 0 10} == 0 then
        defect|{HammerFactory}
    else
        working|{HammerFactory}
    end
end

{System.showInfo "TASK 5 a):"}
local HammerTime B in
    HammerTime = {HammerFactory}
    B = HammerTime.2.2.2.1
    {System.show HammerTime}
end
{System.showInfo ""}



/*
TASK 5 b)
*/
fun {HammerConsumer HammerStream N}
    if N =< 1 then
        if HammerStream.1 == working then 1 else 0 end

    else
        if HammerStream.1 == working then
            1 + {HammerConsumer HammerStream.2 N-1}
        else
            {HammerConsumer HammerStream.2 N-1}
        end
    end
end

{System.showInfo "TASK 5 b):"}
local HammerTime Consumer in
    HammerTime = {HammerFactory}
    Consumer = {HammerConsumer HammerTime 10}
    {System.show Consumer}
end
{System.showInfo ""}



/*
TASK 5 c)
*/
fun {BoundedBuffer ProducerStream N}
    % Generate N first elements in the producer stream. StreamEnd points to the (current) end of the producer stream.
    % We let this run on a separate thread so the consumer don't block while the buffer is filled initially.
    StreamEnd = thread {List.drop ProducerStream N} end

    % This lazy function returns a new element from the producer stream.
    % The StreamEnd variable should point to the current end of the producer stream, and is needed so we can re-fill the buffer with a new element.
    fun lazy {GetFromStream ProducerStream StreamEnd}
        case ProducerStream of Head|Tail then                 % Take the topmost element and the rest from the producer stream.
            Head|{GetFromStream Tail thread StreamEnd.2 end}  % Return the top element, and the rest of the stream whenever it's needed.
            % The StreamEnd.2 statement makes the producer stream produce a new element ahead of time, making the buffer always contain N elements.
            % We let requests to the producer stream happen on a separate thread, so the consumer don't have to wait while the next element is generated.
        end
    end
in
    % Start by returning the first element.
    {GetFromStream ProducerStream StreamEnd}
end

{System.showInfo "TASK 5 c):"}

local HammerStream Consumer in
    {System.showInfo "Without bounded buffer"}
    HammerStream = {HammerFactory}
    {Delay 6000}
    Consumer = {HammerConsumer HammerStream 10}
    {System.show Consumer}
end

local HammerStream Buffer Consumer in
    {System.showInfo "With bounded buffer"}
    HammerStream = {HammerFactory}
    Buffer = {BoundedBuffer HammerStream 6}
    {Delay 6000}
    Consumer = {HammerConsumer Buffer 10}
    {System.show Consumer}
end



{Application.exit 0}

end
