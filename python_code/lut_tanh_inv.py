import numpy as np
file1 = open("lut_tanh_inv.txt","w")
# file1.write("hi")
LUT_SIZE = 8
tans = [0.0]*LUT_SIZE
sum=0
BIT_PRECISION=32
arctanh = np.double(np.arctanh(2**(-1)))
# print(arctanh)

# print(arctanh)
# scale up to a 32 bit signed integer by multiplying floating point num by 2^31. msb becomes sign bit, msb-1 is .5 bit, msb-2 is .25 bit...
# now we can treat 32 bits as s[0][31] fixed point
for i in range(-2,LUT_SIZE-2):
    if i <=0:
        arctanh = np.double(np.arctanh(1-2**(i-2)))
    else:
        arctanh = np.double(np.arctanh(2**(-i)))

    # print(arctanh)
    # scale up to a 32 bit signed integer by multiplying floating point num by 2^30. msb becomes sign bit, msb-1 is 1 bit, msb-2 is .5 bit.... range of -2 to 1.999
    # cordic will add these tan numbers so we need to leave an extra bit to reach range of 2
    # now we can treat 32 bits as s[1][30] fixed point
    if BIT_PRECISION==32:
        scaled = np.uint32(arctanh*2**(BIT_PRECISION-2))
    elif BIT_PRECISION==16:
        scaled = np.uint32(arctanh*2**(BIT_PRECISION-2))
    else:
        scaled = np.uint8(arctanh*2**(BIT_PRECISION-2))
    tans[i%LUT_SIZE] = scaled 

for case in range(LUT_SIZE): # the negative i values
    line = "4'd"+str(case)+": inv_tanh = "+"{}'d".format(BIT_PRECISION)+str(tans[case])+";\n"
    line = "4'd"+str(case)+": inv_tanh = "+"{}'b".format(BIT_PRECISION)+("{0:=0"+str(BIT_PRECISION)+"b}").format(tans[case])+";\n"
    # bin_string = format(case, '0{}b'.format(bits))
    file1.write(line)

# for case in range(1, 14): # positive i values
#     line = "4'd"+str(case)+": inv_tanh = "+"{}'d".format(BIT_PRECISION)+str(tans[case])+";\n"
#     # bin_string = format(case, '0{}b'.format(bits))
#     file1.write(line)
#     # print(line)


file1.close()
# print("max of tan funct is: ", np.double(tans[32]/(2**31)))
# print("tanh(0) is: ", np.double(tans[0]/(2**31)))








# tan_index = 4 # we should see equal number of +1 and -1
# tanh = tans[tan_index]
# sum = 0
# steps = 10000
# for i in range(0,steps):
#     rand_int = np.random.randint(low=np.int32(-2**31), high=np.int32(2**31-1))
#     if (rand_int>=0 and tanh >= 0): # both positive
#         sum += 1
#     elif (rand_int ^ tanh < 0) and ((rand_int+tanh) >= 0): # different signs but sum is positive
#         sum += 1
#     else: # negative sum
#         sum -= 1
# print("sum is: ", sum)
# print("average val is: ", sum/steps)
# print('expected average val tanh(', tan_index/4, '): ', np.tanh(tan_index/4))

# print(np.tanh(4/4))
