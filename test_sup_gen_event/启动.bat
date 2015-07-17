cd ebin
erl  -sname local_node -setcookie "ericlw" -eval "application:start(test_sup)"