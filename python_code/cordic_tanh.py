# software implementation of cordic for tanh
# testing algorithm in numpy before doing hw implementation
# Alex Hoffman
import numpy as np 
import matplotlib.pyplot as plt

tanh_in = 5
def tanh_cordic(tanh_in, n=4):
    theta=alpha=0.0
    x=1
    y=0
    z=tanh_in
    d=0
    for i in range(-2, n+1):
        if i <= 0:
            alpha = 1-np.power(2.0,i-2)
        else:
            alpha = np.power(2.0,-i)
        theta = np.arctanh(alpha)
        # compute d=1 if z<0, d=-1 if z>=0
        d = 2 * int(z<0) - 1
        x_next =          x - d*alpha*y
        y      = -d*alpha*x +         y
        x = x_next
        z = z + d*theta
    return y/x

# construct values in lut
lut_size=8
tans=[0.0]*lut_size
bit_precision=32
for i in range(1,lut_size-2):
    arctanh = np.double(np.arctanh(2**(-i)))

    # print(arctanh)
    # scale up to a 32 bit signed integer by multiplying floating point num by 2^30. msb becomes sign bit, msb-1 is 1 bit, msb-2 is .5 bit.... range of -2 to 1.999
    # cordic will add these tan numbers so we need to leave an extra bit to reach 
    # now we can treat 32 bits as s[1][30] fixed point
    scaled = np.uint32(arctanh*2**(bit_precision-2))
    tans[i] = scaled # move decimal place 31 to the right
    # print("{0:=032b}".format(scaled))
for i in range(-2,1):
    # print(1-2**(i-2))
    arctanh = np.double(np.arctanh(1-2**(i-2)))
    scaled = np.uint32(arctanh*2**(bit_precision-2)) # move decimal place 30 to the right
    tans[i%lut_size] = scaled 

def tanh_cordic_usinglut(tanh_in, n=4, bits=32):
    theta=alpha=0.0
    x=1
    y=0
    z=tanh_in
    d=0
    for i in range(-2, n+1):
        if i <= 0:
            alpha = 1-np.power(2.0,i-2)
        else:
            alpha = np.power(2.0,-i)
        theta_old = np.arctanh(alpha)
        # print(i%16)
        theta=np.float(tans[i%lut_size])*np.power(2.0,-(bits-2)) # convert back to float
        # theta2 = tans[i%16]
        print(tans[i%lut_size],theta_old, theta)
        # compute d=1 if z<0, d=-1 if z>=0
        d = 2 * int(z<0) - 1
        x_next =          x - d*alpha*y
        y      = -d*alpha*x +         y
        x = x_next
        z = z + d*theta
    return y/x


# tanh_cordic_usinglut(.7)
fig1=plt.figure(1)
fig1.suptitle("Python CORDIC Tanh error")
fig2 = plt.figure(2)
fig2.suptitle("Python CORDIC Tanh")
z_array=np.linspace(-4,3.75,num=32)
for n in range(1,5):
    errors = []
    cordics = []
    for z in z_array:
        expected = np.tanh(z)
        cordic = tanh_cordic_usinglut(z, n)
        # cordic=tanh_cordic(z,n)
        errors.append(np.abs(cordic-expected))
        cordics.append(cordic)
    # print(errors)
    plt.figure(1)
    plt.subplot(2,2,n)
    plt.title("Error: N={}".format(n))
    plt.plot(z_array, errors)
    plt.axis([-4,3.75,0,.8])

    plt.figure(2)
    plt.subplot(2,2,n)
    plt.plot(z_array, cordics)
    plt.title("TANH: N={}".format(n))
    plt.axis([-4,3.75,-1,1])
plt.show()
