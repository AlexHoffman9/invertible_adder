import numpy as np
file1 = open("lut.txt","w")
# file1.write("hi")
bits = 6
num_cases = np.power(2,bits)
tans = []

for i in range(0,33):
    tan = np.double(np.tanh(i/4))  # double precision output of tanh
    
    # scale up to a 32 bit signed integer by multiplying floating point num by 2^30
    # now we can treat 32 bits as s[0][31] fixed point
    scaled = np.int32(tan*2**30) # changes magnitude from 1 bit to 31 bits
    tans.append(scaled)
print(tans)

for case in range(np.int32(num_cases/2),0, -1): # -32 to -1 inclusive
    line = "-6'd"+str(case)+": out = "+"-32'd"+str(tans[case])+";\n"
    # bin_string = format(case, '0{}b'.format(bits))
    file1.write(line)
    print(line)

for case in range(0, np.int32(num_cases/2)): # 0 to 31 inclusive
    line = "6'd"+str(case)+": out = "+"32'd"+str(tans[case])+";\n"
    # bin_string = format(case, '0{}b'.format(bits))
    file1.write(line)
    print(line)
file1.close()

print(np.tanh(4/4))
