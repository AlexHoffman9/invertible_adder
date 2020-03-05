import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('../ripple_adder/test_data/t1.csv')
# df = pd.read_csv('t2.csv')
(rows,cols) = df.shape
# rows = int(rows/10) # want to look at first 1000 cycles

# get column indices
a_index = df.columns.get_loc('A')
b_index = df.columns.get_loc('B')
s_index = df.columns.get_loc('S')
ovf_index = df.columns.get_loc('OVF')

# print(df.iloc[0:,df.columns.get_loc('Steps')])
start_index = 0
while start_index < rows:                           # iterate through tests 
    I_0 = df.iloc[start_index,df.columns.get_loc('OVF')]
    mode = int(df.iloc[start_index,df.columns.get_loc('Mode')])
    steps = int(df.iloc[start_index,df.columns.get_loc('Steps')])
    # print(df.iloc[start_index,0:])
    # print(mode)
    if mode == 0:  # Addition mode. Check sum for accuracy
        # Adder Accuracy
        a=df.iloc[start_index,a_index]; b=df.iloc[start_index,b_index]
        target = (a+b)%16
        equality_list = target==df.iloc[start_index:start_index+steps,s_index]                   # boolean list of whether sum was correct
        num_chunks = 10; chunk_size = int(np.floor(steps/num_chunks))
        accuracy_list = []                                            # list of accuracy across batches of size chunk_size
        for i in range(num_chunks):
            accuracy_list.append(np.sum(equality_list[chunk_size*i:chunk_size*(i+1)])/chunk_size)
        sum_correct = np.sum(equality_list)
        # print(sum_correct/steps)

        # Figure for addition
        fig=plt.figure()
        fig.suptitle("Results for Addition S=A+B: A={}, B={}, I0={}".format(a,b,I_0))

        # Plot accuracy over time
        plt.subplot(1,2,1)
        # print(np.arange(0,steps,chunk_size))
        # print(accuracy_list)
        plt.plot(np.arange(0,steps,chunk_size), accuracy_list)
        plt.title("Adder accuracy over time")
        plt.xlabel("Cycles")
        plt.ylabel("Accuracy")
        plt.axis([0,steps, 0, 1])

        # Plot histogram of sum
        sum_histogram = np.bincount(df.iloc[0:steps,s_index], minlength=16)
        normalized_sum_histogram = np.divide(sum_histogram,steps)  # normalize to frequency 1
        # print(normalized_sum_histogram)
        plt.subplot(1,2,2)
        plt.bar(range(16), normalized_sum_histogram)
        plt.title("Histogram of adder sum")
        plt.xlabel("Observed Sum")
        plt.ylabel("Frequency")
        

    elif mode==2:  # subtraction mode. Check b for accuracy
        # print('h')
        a=df.iloc[start_index,a_index]; s=df.iloc[start_index,s_index]
        target = s-a
        if target < 0:
            target += 16
        # print(target)
        equality_list = target==df.iloc[start_index:start_index+steps,b_index]                   # boolean list of whether sum was correct
        # print(equality_list)
        num_chunks = 10; chunk_size = int(np.floor(steps/num_chunks))
        accuracy_list = []                                            # list of accuracy across batches of size chunk_size
        for i in range(num_chunks):
            accuracy_list.append(np.sum(equality_list[chunk_size*i:chunk_size*(i+1)])/chunk_size)
        sum_correct = np.sum(equality_list)

        # Figure for Subtraction
        fig=plt.figure()
        fig.suptitle("Results for Subtraction B=S-A: A={}, S={}, I0={}".format(a,s,I_0))

        # Plot accuracy over time
        plt.subplot(1,2,1)
        # print(np.arange(0,steps,chunk_size))
        # print(accuracy_list)
        plt.plot(np.arange(0,steps,chunk_size), accuracy_list)
        plt.title("Subtraction accuracy over time")
        plt.xlabel("Cycles")
        plt.ylabel("Accuracy")
        plt.axis([0,steps, 0, 1])

        # Plot histogram of sum
        sum_histogram = np.bincount(df.iloc[start_index:start_index+steps,b_index], minlength=16)
        # print(sum_histogram)
        normalized_sum_histogram = np.divide(sum_histogram,steps)  # normalize to frequency 1
        # print(normalized_sum_histogram)
        plt.subplot(1,2,2)
        plt.bar(range(16), normalized_sum_histogram)
        plt.title("Histogram of B=S-A")
        plt.xlabel("Observed B")
        plt.ylabel("Frequency")

    start_index += steps+1
    # print(start_index)
plt.show()