from collections import deque

# remove first item
[1, 2, 3]

# when the list is large, it can have high impact on memory
#  it's more efficient to use deque in that case
queue = deque([])  # has few similar methods with list

queue.append(1)
queue.append(2)
queue.append(3)

queue.popleft()  # remove an item from the beginning of the queue
print(queue)

if not queue:
    print("empty")
