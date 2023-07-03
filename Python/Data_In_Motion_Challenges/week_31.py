## very easy

#  function that takes the base and height of a triangle and return its area.
def area(base, height):
    area=(base*height)/2
    return area

print(area_triangle(3,2))

## easy

#  function that takes an integer and returns the factorial of that integer.
def factorial(num):
#     if number is 1 factorial is 1
    if num == 1:
        factorial = 1
    else:
#         if number is greater than 1 assign a variable factorial and use a for loop to find the factorial
        factorial=1
        for i in range(1,num+1):
           
            factorial=factorial*i
    print ("The factorial of "+ str(num)+ " is "+ str(factorial))   
        


factorial(7)

## medium

# function that takes three values, hours, minutes, seconds and return the longest duration
def duration(h,m,s):
    
#     change hours and minutes to seconds to compare

    h_to_sec = h*3600
    m_to_sec = m*60
    
#     comparisions using if statements
    if h_to_sec > m_to_sec and h_to_sec > s:
        return h
    if m_to_sec > h_to_sec and m_to_sec > s:
        return m
    if s > h_to_sec and s > m_to_sec:
        return s
    
duration(15, 955, 59400)


## hard

# function to return a set of words in the plural form if they appear more than once in the list of singular form

def pluralize(my_list):
#     create a new list for plural form
    new_list=[]
    
#     check how many time an item appears in list using count() in full list by iterating
    for i in range(len(my_list)):
        counts=my_list.count(my_list[i])
        
#     if the item appears more than ones add "s"
        if counts==1:
            item=my_list[i]
        elif counts>1:
            item=my_list[i] + "s"
            
#     if the item already in new list leave it or else add it using append()
        if item in new_list:
            pass
        else:
            new_list.append(item)
    print(new_list)       

pluralize(["cow", "pig", "cow", "cow", "pig", "dog"])
