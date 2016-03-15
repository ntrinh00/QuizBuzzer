# QuizBuzzer

Attempt to learn LUA using Node MCU, buliding a tcp/ip buzzer with html interface.

First attempt was to use UDP for speed by remove TCP negotiation. UDP over wireless did't not yield good results so implemented a TCP version. After some timing comparison, TCP handshake is still way faster than human reflexes and should not be a concern when trying to ensure who buzzed in first. 
