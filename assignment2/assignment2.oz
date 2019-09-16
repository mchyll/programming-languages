functor 
import
    System
define

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PROGRAMMING LANGUAGES - ASSIGNMENT 2 %
% AUTHOR: Magnus Conrad Hyll           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%
% TASK 1 %
%%%%%%%%%%

/*
Helper procedure which prints the elements of a list, separated by spaces.
*/
proc {PrintList List}
    case List of nil then
        {System.showInfo ''}
    [] Head|Tail then
        {System.printInfo Head#' '}
        {PrintList Tail}
    else
        skip
    end
end

/*
Returns the number of elements in :List:.
*/
fun {Length List}
    case List of nil then
        0
    [] Head|Tail then
        1 + {Length Tail}
    end
end

/*
Returns a list with the :Count: first of elements in :List:.
*/
fun {Take List Count}
    if Count < 1 then
        nil
    else
        case List of nil then
            nil
        [] Head|Tail then
            Head|{Take Tail Count-1}
        end
    end
end

/*
Returns a list without the :Count: first elements in :List:.
*/
fun {Drop List Count}
    if Count < 1 then
        List
    else
        case List of nil then
            nil
        [] Head|Tail then
            {Drop Tail Count-1}
        end
    end
end

/*
Returns a list with all elements in :List1: followed by all elements in :List2:.
*/
fun {Append List1 List2}
    case List1 of nil then
        List2
    [] Head|Tail then
        Head|{Append Tail List2}
    end
end

/*
Returns true if :Element: is present in :List:, and false otherwise.
*/
fun {Member List Element}
    case List of nil then
        false
    [] Head|Tail then
        if Head == Element then
            true
        else
            {Member Tail Element}
        end
    end
end

/*
Returns the position of :Element: in :List:, with indexing starting at 0.
Assumes the element is present in the list.
*/
fun {Position List Element}
    case List of Head|Tail then
        if Head == Element then
            0
        else
            1 + {Position Tail Element}
        end
    end
end



%%%%%%%%%%
% TASK 2 %
%%%%%%%%%%
/*
HIGH LEVEL DESCRIPTION OF TASK 2:
mdc starts with an input string in infix notation and passes it to the Lex function. This splits the input
string by whitespace and returns a list of lexemes, which are like the individual "words".
The Tokenize function is then called with the list of lexemes returned from Lex. It then classifies the lexemes
by mapping them to each its corresponding token, which represent the type of "word" that lexeme is (for instance,
23 5 and 8 are number tokens, + and * are operator tokens and p and i are command tokens). This returns a list
of tokens which is then passed to the Interpret function, which does the calculations to find the final result of
the given expression. It iterates through all tokens using pattern matching and recursion. The function operates
with a number stack, where each encountered number token is pushed on top of the stack.
When encountering an operator token, the two topmost elements on the number stack is popped and used in the
calculation of the operator. The result is then pushed on top of the number stack. When all tokens are processed,
the resulting number stack is returned, which contain the final result of the given expression.
*/

/*
Lexemizes a string.
Splits the input string by whitespace and returns a list of lexemes.
Raises an exception if the input is not a string.
*/
fun {Lex Input}
    if {IsString Input} then
        {String.tokens Input & }
    else
        raise 'Input is not a string' end
    end
end

/*
Tokenizes a list of lexemes.
Classifies the lexemes by mapping the list of lexemes to each its corresponding token.
Raises an exception if the list contains an invalid lexeme, that is, a lexeme which is not
recognized and can't be mapped to a token.
*/
fun {Tokenize Lexemes}
    {Map Lexemes
        fun {$ Lexeme}
            if Lexeme == "+" then operator(type:plus)
            elseif Lexeme == "-" then operator(type:minus)
            elseif Lexeme == "*" then operator(type:multiply)
            elseif Lexeme == "/" then operator(type:divide)
            elseif Lexeme == "p" then command(print)
            elseif Lexeme == "d" then command(duplicatetop)
            elseif Lexeme == "i" then command(flipsign)
            elseif Lexeme == "^" then command(mulinverse)
            else
                try number({String.toFloat Lexeme})
                catch Exception then
                    raise 'Invalid lexeme' end
                end
            end
        end
    }
end

/*
Interprets a list of tokens by processing commands and operators, and returns the resulting number stack.
The function operates with a number stack, where each encountered number token is pushed on top of the stack.
When encountering an operator token, the two topmost elements on the number stack is popped and used in the
calculation of the operator. The result is then pushed on top of the number stack. When all tokens are processed,
the resulting number stack is returned.
*/
fun {Interpret Tokens}
    % Maps command names to their corresponding functions
    CommandFunctions = commandFunctions(
        % Command 'p': prints the whole stack and returns the stack unaltered.
        print: fun {$ NumberStack}
            % Reverse the stack, tokenize the numbers and print
            {System.show {Tokenize {Reverse NumberStack}}}
            NumberStack
        end

        % Command 'd': Duplicates the top element on the stack, and returns the stack.
        duplicatetop: fun {$ NumberStack}
            case NumberStack of Head|Tail then
                Head|Head|Tail
            else
                raise 'Stack is empty' end
            end
        end

        % Command 'f': Flips the sign of the top element on the stack, and returns the stack.
        flipsign: fun {$ NumberStack}
            case NumberStack of Head|Tail then
                ~Head|Tail
            else
                raise 'Stack is empty' end
            end
        end

        % Command '^': Replaces the top elements by its multiplicative inverse (that is, x^(-1)), and returns the stack.
        mulinverse: fun {$ NumberStack}
            case NumberStack of Head|Tail then
                (1.0 / Head)|Tail
            else
                raise 'Stack is empty' end
            end
        end
    )

    % Maps operator names to their mathematical function
    OperatorFunctions = operatorFunctions(
        plus:     fun {$ X Y} X + Y end
        minus:    fun {$ X Y} X - Y end
        multiply: fun {$ X Y} X * Y end
        divide:   fun {$ X Y} X / Y end
    )

    % Internal function which actually does the processing of the tokens.
    % Iterates through the tokens using pattern matching and by calling itself recursively.
    fun {ProcessTokens Tokens NumberStack}
        case Tokens of number(N)|RemainingTokens then
            % "Push" number on stack by calling itself with the current stack including the number as the first element
            {ProcessTokens RemainingTokens N|NumberStack}

        [] command(Cmd)|RemainingTokens then
            % Run the corresponding command with the current stack
            {ProcessTokens RemainingTokens {CommandFunctions.Cmd NumberStack}}

        [] operator(type:Op)|RemainingTokens then
            % Take two top elements on stack, calculate and put the result on top of the stack
            case NumberStack of Top|Second|RemainingStack then
                {ProcessTokens RemainingTokens {OperatorFunctions.Op Second Top}|RemainingStack}
            else
                raise 'Not enough numbers on stack' end
            end

        [] nil then
            % No more tokens to process, reverse the stack and tokenize the numbers on the stack
            {Tokenize {Reverse NumberStack}}

        end
    end
in
    % Start processing the tokens with an empty stack
    {ProcessTokens Tokens nil}
end



%%%%%%%%%%
% TASK 3 %
%%%%%%%%%%
/*
HIGH LEVEL DESCRIPTION OF TASK 3:
The Infix function starts by calling the inner InfixInternal function with the list of tokens and an
empty expression stack (nil). InfixInternal then checks the topmost token in :Tokens: using pattern matching.
If it's a number, it is added to the top of the expression stack, and InfixInternal calls itself recursively 
to process the remaining tokens with the new expression stack.
If the token is an operator, the two topmost elements in the expression stack is popped. These are combined
to a new expression as a virtualstring on the form "(second-to-top-expression operator top-expression)".
This expression is then put on top of the expression stack, and InfixInternal is called recursively to
process the remaining tokens.
When InfixInternal finally is called with an empty token list, the expression stack is simply returned.
This results in a non-ambiguous representation of the whole expression in infix notation.
*/

/*
Converts a list of tokens in postfix notation to a string containing the whole expression in infix notation.
Assumes the list of tokens represent a valid infix notation expression.
For instance, the list [number(1) operator(type:plus)] is invalid.
*/
fun {Infix Tokens}
    fun {InfixInternal Tokens ExpressionStack}
        % Maps operator names to symbols
        OperatorMap = operatorMap(
            plus:     '+'
            minus:    '-'
            multiply: '*'
            divide:   '/'
        )
    in
        case Tokens of number(N)|RemainingTokens then
            % Numbers are pushed on the stack
            {InfixInternal RemainingTokens N|ExpressionStack}

        [] operator(type:Op)|RemainingTokens then
            Top|Second|RemainingExpressions = ExpressionStack in
                {InfixInternal RemainingTokens "("#Second#" "#OperatorMap.Op#" "#Top#")"|RemainingExpressions}

        [] nil then
            % No more tokens, return the complete expression
            ExpressionStack
        end
    end
in
    % InfixInternal returns a list, return the first element which is a virtualstring of the whole expression
    {InfixInternal Tokens nil}.1
end



% Expressions testing the individual functions

{System.show {Lex "hehe 123 +"}}
{System.show {Tokenize {Lex "123 321 + ^"}}}
{System.show {Tokenize ["1" "2" "+" "3" "*"]}}
{System.show {Interpret {Tokenize {Lex "4 5 + 2 *"}}}}
% {System.show {Interpret {Tokenize {Lex "4 +"}}}}
% {System.show {Interpret {Tokenize {Lex 1}}}}
{System.showInfo {Infix {Tokenize {Lex "3.0 10.0 9.0 * - 0.3 +"}}}}
% {System.showInfo {Infix {Tokenize {Lex "0.3 +"}}}}


end  % End define
