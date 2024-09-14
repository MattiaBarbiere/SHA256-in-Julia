#Note: In this project hex and decimal numbers will be used as strings

#####################Functions######################

#This function converts a decimal number to binary format
function decimal_to_binary(num, padding = 8)
    return string(num, base = 2, pad=padding)
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

message = "RedBlockBlue hello how are you doing this fine morning. I am doing well thank you,  \
# I heared that I was not"
# message = "RedBlockBlue hello how are you doing this fine morning. I am doing well thank you,  \
# I heared that I was not having lunch time with bob and Gill and I know that eventually life comes at you\
# fast enough that not even light could catch it, defing the laws of einstein"

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

    #Making sure the size is correct
    @assert length(bit_string) % 512 == 0 "Bit string is not padded correctly"
    return bit_string
end

test = padding(sentence_to_binary(message))
#println(test, length(test))

#A function that splits a bit string into many chunks of size n
function split_into_chunks(bit_string, n)
    #We assume that the input is of the correct length
    @assert length(bit_string) % n == 0 "The input bit string is not of the correct length" 
    
    chunks = []
    i = 1
    #Iterating over the bit_string
    while i < lastindex(bit_string)
        #Recalling that Julia starts counting from 1 and the end in included
        push!(chunks, bit_string[i:i+n-1])
        i += n
    end

    for i in 1:lastindex(chunks)
        #Making sure that the block are all of the right size
        @assert length(chunks[i]) == n "Chunks are not of the correct length"
    end
    return chunks  
end

#Some constants
init_hash = [
0x6a09e667,
0xbb67ae85,
0x3c6ef372,
0xa54ff53a,
0x510e527f,
0x9b05688c,
0x1f83d9ab,
0x5be0cd19]

init_K = [0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2]
println(init_K[7])

# #This is useless but it helps us check that the initial hashes are correct
# function init_hash_calc()
#     h = []
#     p = [2, 3, 5, 7, 11, 13, 17]
#     for prime in p
#         s = sqrt(prime)
#         #Only take the fractional part
#         s = s - floor(s)

#         #Cut of the "0."
#         s = string(s)[3:16]

#         #Make s and integer again
#         s = parse(Int64, s)

#         #Make s in binary with size 32
#         s = decimal_to_binary(s)[1:31]
        
#         #Add a missing 0
#         s = "0"*s
#         println(length(s))
#         #Add to the hash list
#         push!(h, binary_to_hex(s))
#     end
#     return h
# end
# println(init_hash_calc())


#The function that gives us the hashed message
function SHA256(message)
    #We transform the message to binary
    bit_string = sentence_to_binary(message)

    #The Preprossesing step
    bit_string = padding(bit_string)

    #Generate the blocks of size 512
    blocks = split_into_chunks(bit_string, 512)

    #We iterate over the blocks
    for b in blocks
        #The block is then split into 16 32bit blocks
        W = split_into_chunks(b, 32)

        #Making sure there is the right amount
        @assert length(W) == 16 "The blocks were not divided correctly"
    
    end
    return blocks
end

#println(SHA256(message))