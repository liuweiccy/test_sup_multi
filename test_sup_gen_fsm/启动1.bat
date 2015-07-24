cd ebin
erl  -sname local_node1 -setcookie "ericlw" -eval "application:start(test_sup),net_adm:ping(local_node@liuwei)"