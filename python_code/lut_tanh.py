import numpy as np
file1 = open("lut.txt","w")
# file1.write("hi")
bits = 6
num_cases = np.power(2,bits)
tans = []

for i in range(0,33):
    tan = np.double(np.tanh(i/4))  # double precision output of tanh
    
    # scale up to a 32 bit signed integer by multiplying floating point num by 2^31. msb becomes sign bit, msb-1 is .5 bit, msb-2 is .25 bit...
    # now we can treat 32 bits as s[0][31] fixed point
    scaled = np.int32(tan*2**31) # changes magnitude from 1 bit to 31 bits
    tans.append(scaled)
print(tans)

for case in range(np.int32(num_cases/2),0, -1): # -32 to -1 inclusive
    line = "-6'd"+str(case)+": out = "+"-32'd"+str(tans[case])+";\n"
    # bin_string = format(case, '0{}b'.format(bits))
    file1.write(line)
    # print(line)

for case in range(0, np.int32(num_cases/2)): # 0 to 31 inclusive
    line = "6'd"+str(case)+": out = "+"32'd"+str(tans[case])+";\n"
    # bin_string = format(case, '0{}b'.format(bits))
    file1.write(line)
    # print(line)
file1.close()
# print("max of tan funct is: ", np.double(tans[32]/(2**31)))
# print("tanh(0) is: ", np.double(tans[0]/(2**31)))

tan_index = 4 # we should see equal number of +1 and -1
tanh = tans[tan_index]
sum = 0
steps = 10000
for i in range(0,steps):
    rand_int = np.random.randint(low=np.int32(-2**31), high=np.int32(2**31-1))
    if (rand_int>=0 and tanh >= 0): # both positive
        sum += 1
    elif (rand_int ^ tanh < 0) and ((rand_int+tanh) >= 0): # different signs but sum is positive
        sum += 1
    else: # negative sum
        sum -= 1
print("sum is: ", sum)
print("average val is: ", sum/steps)
print('expected average val tanh(', tan_index/4, '): ', np.tanh(tan_index/4))

