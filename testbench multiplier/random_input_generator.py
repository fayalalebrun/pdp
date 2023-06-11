# -*- coding: utf-8 -*-
"""
Created on Sun Jun 11 10:57:45 2023

@author: kekha
"""
import random

a_test = "a_test({}) <= std_logic_vector(to_signed({}, 32));\n"
b_test = "b_test({}) <= std_logic_vector(to_signed({}, 32));\n"
a_test_u = 'a_test({}) <= "{}"; \n'
b_test_u = 'b_test({}) <= "{}"; \n'


max_int = 2147483647
min_int = -2147483648
max_unsigned = 4294967295

a_tests = list()
b_tests = list()
a_tests_u = list()
b_tests_u = list()

for index in range(202):
    if index <= 100:
         a_tests.append(a_test.format(index, random.randint(min_int, max_int)))
         b_tests.append(b_test.format(index, random.randint(min_int, max_int)))
    else:
         a_tests_u.append(a_test_u.format(index, '{:032b}'.format(random.randint(0, max_unsigned))))
         b_tests_u.append(b_test_u.format(index, '{:032b}'.format(random.randint(0, max_unsigned))))


with open("new_file.txt", "w") as f:
    f.writelines(a_tests)
    f.writelines(a_tests_u)
    f.write("\n")
    f.writelines(b_tests)
    f.writelines(b_tests_u)
        
    