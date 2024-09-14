#Note: In this project hex and decimal numbers will be used
# as strings
char = 'a'
ascii_code = Int(char)


#####################Functions######################

#This function converts a decimal number to binary format
function decimal_to_binary(num)
    #I have to double check that the number is 8 bits long (pad=8)
    return string(num, base = 2, pad=8)
end

#To go from binary to decimal
function binary_to_decimal(num)
    return parse(Int64, num, base=2)
end

#A function that converts from binary to hexadecimal
function binary_to_hex(num::String)
    return string(binary_to_decimal(num), base = 16)
end

#From hexadecimal to binary
function hex_to_binary(num::String)
    num = parse(Int64,"0x" * num)
    return string(num, base=2)
end

#Testing to make sure the conversion functions work
# test = 170
# print(test, "\n")
# c = decimal_to_binary(test)
# println(c)
# d = binary_to_hex(c)
# println(d)
# f = hex_to_binary(d)
# println(f)
# g = binary_to_decimal(f)
# println(g)

function word_to_binary(word::String)
    result = ""
    for i in word
        result *= decimal_to_binary(Int(i)) * " "
    end 
    return result   
end

