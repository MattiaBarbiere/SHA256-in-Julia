#Note: In this project hex and decimal numbers will be used as strings

#####################Functions######################

#This function converts a decimal number to binary format
function decimal_to_binary(num; padding=8)
    return string(num, base = 2, pad=padding)
end

#To go from binary to decimal
function binary_to_decimal(num)
    return parse(Int128, num, base=2)
end

#A function that converts from binary to hexadecimal
function binary_to_hex(num::String)
    if length(num) < 64
        return string(binary_to_decimal(num), base = 16)
    else
        #This is for extra long bit strings
        result = ""
        i = 1
        while i < length(num)
            #We do increments of 64
            increment = min(63, length(num)-i)
            result *= string(binary_to_decimal(num[i:i+increment]), base = 16)
            i += 64
        end
    end
    return result
end

#From hexadecimal to binary
function hex_to_binary(num::String; padding=8)
    num = parse(Int64,"0x" * num)
    return string(num, base=2, pad=padding)
end


#A single word into binary
function word_to_binary(word)
    result = raw""
    for i in word
        result *= decimal_to_binary(Int(i))
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
    #println("Here ", len_in_binary, " ", len)

    #Final concatination
    bit_string *= len_in_binary

    #Making sure the size is correct
    @assert length(bit_string) % 512 == 0 "Bit string is not padded correctly"
    return bit_string
end


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
"6a09e667",
"bb67ae85",
"3c6ef372",
"a54ff53a",
"510e527f",
"9b05688c",
"1f83d9ab",
"5be0cd19"]

#Transform it into bits
for i in 1:lastindex(init_hash)
    init_hash[i] = hex_to_binary(init_hash[i], padding=32)
end

K = ["428a2f98", "71374491", "b5c0fbcf","e9b5dba5", "3956c25b", "59f111f1", "923f82a4", "ab1c5ed5",
"d807aa98", "12835b01", "243185be", "550c7dc3", "72be5d74", "80deb1fe", "9bdc06a7", "c19bf174",
"e49b69c1", "efbe4786", "0fc19dc6", "240ca1cc", "2de92c6f", "4a7484aa", "5cb0a9dc", "76f988da",
"983e5152", "a831c66d", "b00327c8", "bf597fc7", "c6e00bf3", "d5a79147", "06ca6351", "14292967",
"27b70a85", "2e1b2138", "4d2c6dfc", "53380d13", "650a7354", "766a0abb", "81c2c92e", "92722c85",
"a2bfe8a1", "a81a664b", "c24b8b70", "c76c51a3", "d192e819", "d6990624", "f40e3585", "106aa070",
"19a4c116", "1e376c08", "2748774c", "34b0bcb5", "391c0cb3", "4ed8aa4a", "5b9cca4f", "682e6ff3",
"748f82ee", "78a5636f", "84c87814", "8cc70208", "90befffa", "a4506ceb", "bef9a3f7", "c67178f2"]

#Transformation into bits
for i in 1:lastindex(K)
    K[i] = hex_to_binary(K[i], padding=32)
end

#println(add_space(padding(word_to_binary("hello world"))))
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

##The rotation functions

#The rotation functions which rotates the bit r times
function RotR(x, r)
    for i in 1:r
        last_bit = x[lastindex(x)]
        x = last_bit * x[1:lastindex(x)-1]
    end
    return x
end

#The right sheer function
function ShR(x, s)
    for i in 1:s
        x = "0" * x[1:lastindex(x)-1]
    end
    return x
end

#Bit wise sum (mod 2) over three bit strings
function bit_wise_sum(x,y,z=nothing)
    #Make sure the strings all have the same length
    @assert length(x) == length(y) "The strings are not the same length"

    #In case z is nothing we just make it a string of zeros
    if z === nothing
        z = lpad(0,length(x), "0")
    else
        #Otherwise we make sure that the lengths match
        @assert length(x) == length(z) "The strings are not the same length"
    end

    result = ""
    for i in 1:lastindex(x)
        sum = (parse(Int64, x[i]) + parse(Int64,y[i]) + parse(Int64,z[i]))%2
        result = result * string(sum)
    end
    return result
end


#This is the sigma 0 function that is used in the calculation
function sigma_0(x)
    #Rotation of 7
    r1 = RotR(x, 7)
    # println("r1 ", add_space(r1))

    #Rotation of 18
    r2 = RotR(x, 18)
    # println("r2 ", add_space(r2))

    #Shear of 3
    r3 = ShR(x, 3)
    # println("r3 ", add_space(r3))
    return bit_wise_sum(r1, r2, r3)
end

#This is the sigma 1 function that is used in the calculation
function sigma_1(x)
    #Rotation of 17
    r1 = RotR(x, 17)

    #Rotation of 19
    r2 = RotR(x, 19)

    #Shear of 10
    r3 = ShR(x, 10)
    return bit_wise_sum(r1, r2, r3)
end


function cap_sigma_0(x)
    #Rotation of 2
    r1 = RotR(x, 2)

    #Rotation of 13
    r2 = RotR(x, 13)

    #Rotation of 22
    r3 = RotR(x, 22)
    return bit_wise_sum(r1, r2, r3)
end


function cap_sigma_1(x)
    #Rotation of 6
    r1 = RotR(x, 6)

    #Rotation of 11
    r2 = RotR(x, 11)

    #Rotation of 25
    r3 = RotR(x, 25)
    return bit_wise_sum(r1, r2, r3)
end



function sum_32_bits(x, y, z=0, w=0, v=0)
    len_x = length(x)
    #Making sure dimensions match (mathematically we could add them however for my purpose they should all be the same length)
    @assert len_x == length(y) "Bit strings do not have the same length, y"

    #Convert the numbers to decimal
    x = binary_to_decimal(x)
    y = binary_to_decimal(y)
    if z != 0
        @assert len_x == length(z) "Bit strings do not have the same length, z"
        z = binary_to_decimal(z)
    end
    if w != 0
        @assert len_x == length(w) "Bit strings do not have the same length, w"
        w = binary_to_decimal(w)
    end
    if v != 0
        @assert len_x == length(v) "Bit strings do not have the same length, v"
        v = binary_to_decimal(v)
    end
    res = (x + y + z + w + v) % 2^32

    return decimal_to_binary(res; padding=32)
end


#A function that takes the bit wise complement of a bit string
function NOT(x)
    result = ""
    for i in 1:lastindex(x)
        #If x[i] == 0 then we add 1
        if parse(Int64, x[i]) == 0
            result *= "1"
        #If x[i] == 1 then we add 0
        elseif parse(Int64, x[i]) == 1
            result *= "0"
        else
            #If we did not recieve a bit string as input
            @assert false "String is not a bit string"
        end
    end
    return result
end


#A function that take the bit wise AND operator
function AND(x, y)
    #We make sure the inputs are of the same length
    @assert length(x) == length(y) "Inputs are not of the same length!"

    result = ""
    for i in 1:lastindex(x)
        s = parse(Int64, x[i]) + parse(Int64, y[i])
        if s == 2
            result *= "1"
        elseif s == 1 || s == 0
            result *= "0"
        else
            @assert false "Inputs are not valid bit strings"
        end
    end
    return result
end


function Ch(x, y, z)
    return bit_wise_sum(AND(x, y), AND(NOT(x), z))
end


function Maj(x, y, z)
    return bit_wise_sum(AND(x, y), AND(x, z), AND(y, z))
end

#A function that concatinates all the values in a list of bit strings
function conc(array)
    result = ""
    for i in array
        result *= i
    end
    return result
end

#The function that gives us the hashed message
function SHA256(message)
    #We transform the message to binary
    bit_string = word_to_binary(message)

    #The Preprossesing step
    bit_string = padding(bit_string)

    #Generate the blocks of size 512
    blocks = split_into_chunks(bit_string, 512)

    #Initiatlise the Hs
    H = init_hash
   
    #We iterate over the blocks
    for block in blocks
        #The block is then split into 16 32bit blocks
        W = split_into_chunks(block, 32)

        #Making sure there is the right amount
        @assert length(W) == 16 "The blocks were not divided correctly"

        #We loop over all the W values
        for i in 17:64
            #Computing the complete list of W
            next = sum_32_bits(sigma_1(W[i-2]), W[i-7], sigma_0(W[i-15]), W[i-16])
            push!(W, next)
        end

        #Making sure the list W is of correct length
        @assert length(W) == 64 "W is of the wrong length"

        #Following the computation steps
        a = H[1]
        b = H[2]
        c = H[3]
        d = H[4]
        e = H[5]
        f = H[6]
        g = H[7]
        h = H[8]

        for i in 1:64
            T_1 = sum_32_bits(h, cap_sigma_1(e), Ch(e, f, g), K[i], W[i])
            T_2 = sum_32_bits(cap_sigma_0(a), Maj(a, b, c))
            h = g
            g = f
            f = e
            e = sum_32_bits(d, T_1)
            d = c
            c = b
            b = a
            a = sum_32_bits(T_1, T_2)

        end
        
        H[1] = sum_32_bits(H[1], a)
        H[2] = sum_32_bits(H[2], b)
        H[3] = sum_32_bits(H[3], c)
        H[4] = sum_32_bits(H[4], d)
        H[5] = sum_32_bits(H[5], e)
        H[6] = sum_32_bits(H[6], f)
        H[7] = sum_32_bits(H[7], g)
        H[8] = sum_32_bits(H[8], h)

    end

    concatinated_H = conc(H)
    return binary_to_hex(concatinated_H)
end
message = "hello"
# println(length(SHA256(message)))
my_ = SHA256(message)
println(my_)
