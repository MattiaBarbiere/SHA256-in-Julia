#Note: In this project hex and decimal numbers will be used as strings

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

#A single word into binary
function word_to_binary(word)
    result = raw""
    for i in word
        result *= decimal_to_binary(Int(i))
    end 
    return result   
end

#The whole sentence into binary
function sentence_to_binary(sentence)
    result = raw""
    for i in split(sentence, " ")
        result *= word_to_binary(i)
    end
    return result
end

#A function that adds spaces every 8 bits (this is only for visual purposes)
function add_space(bit_string)
    #Make sure there are no spaces already in the bit string
    bit_string = replace(bit_string, " " => "")

    #Transform the string to an array (so we can add element)
    array = split(bit_string, "")
    i = 9
    while i <= length(array)
        insert!(array, i, " ")
        i += 9
    end
    return join(array)
end


############Preprossesing functions###################
message = "RedBlockBlue"
function padding(bit_string)
    #I remove any spaces in the bit_string so that we have strings of the correct dimension
    bit_string = replace(bit_string, " " => "")

    #Calculate the length
    len = length(bit_string)
    
    #The next multiple of 512 after adding the extra 64+1 bits
    multiple = div(len + 65, 512) + 1

    #Calculating the k
    k = 512 * multiple - len - 65

    #Adding the "1" bit
    bit_string *= "1"

    #Adding the extra padding
    bit_string = rpad(bit_string, len + 1 + k, "0")
    
    #The length of the sentence written with 64 bits
    len_in_binary = string(len, base = 2, pad=64)

    #Final concatination
    bit_string *= len_in_binary

    return bit_string
end

c = padding(sentence_to_binary(message))
println(add_space(c))