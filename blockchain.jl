# Blockchain.jl copyright © 2020 Derik Kauffman
# Based on https://hackernoon.com/learn-blockchains-by-building-one-117428612f46
# Original code copyright © 2017 Daniel van Flymen
# Licensed under the MIT license.

module Snowcoin

using SHA: sha256

struct Transaction
    sender::String
    recipient::String
    amount::Int
end

struct Block
    index::Int
    timestamp::Int  # The rough number of seconds since the Unix epoch
    transactions::Vector{Transaction}
    proof::Int
    previous_hash::String
end

mutable struct Blockchain
    chain::Vector{Block}
    pending_transactions::Vector{Transaction}  # "Mempool"
end

"Create a new blockchain with a genesis block"
function Blockchain()
    bc = Blockchain([], [])
	new_block!(bc, 0, shash(rand(Int)))
	return bc
end


function is_valid(bc::Blockchain)
	prev_block = bc.chain[1]
	curr_index = 2

	while curr_index <= length(bc)
		block = bc.chain[curr_index]
		prev_block_hash = shash(prev_block)

		# Check that the hash of the block is correct
		if block.previous_hash != prev_block_hash
			return false
		end

		# Check that the proof of work is correct
		if !valid_proof(prev_block.proof, block.proof, prev_block_hash)
			return false
		end

		prev_block = block
		curr_index += 1
	end

	return true
end

"Create a new block and add it to the chain."
function new_block!(bc::Blockchain, proof, previous_hash)
    block = Block(
        length(bc) + 1,
        round(time()),
        bc.pending_transactions,
        proof,
        previous_hash,
    )

    bc.pending_transactions = []

    push!(bc.chain, block)
    return block
end
new_block!(bc::Blockchain, proof) = new_block!(bc, proof, shash(bc.chain[end]))

"Create a new transaction to go into the next mined block."
function new_transaction!(bc::Blockchain, sender, recepient, amount)
    transaction = Transaction(sender, recepient, amount)
    push!(bc.pending_transactions, transaction)

    return bc.chain[end].index + 1
end

# Double hash to prevent against length extension
# TODO: Consider using a different (memory-hard) hash algorithm
#SHA.sha256(x::Integer) = sha256(reinterpret(UInt8, [x]))
shash(x) = x |> string |> sha256 |> sha256 |> bytes2hex

# The number of zero bits that a hash must begin with to constitute a valid proof.
# TODO: Adjust dynamically to hold block time approximately constant.
const DIFFICULTY = UInt8(12)

# The number of snowcoins generated upon successfully mining a block.
# TODO: Adjust dynamically to limit total currency supply.
const REWARD = 120

# The number of units each snowcoin can be subdivided into.
const FLAKES_PER_COIN = 100_000_000


function valid_proof(last_proof, proof, last_hash)
    guess = string(last_proof) * string(proof) * last_hash
    guess_hash = shash(guess)
    return guess_hash <= -1 >>> DIFFICULTY  # True if the first `difficulty` bits are 0
end

function proof_of_work(bc::Blockchain, last_block)
	last_proof = last_block.proof
	last_hash = shash(last_block)

    # The address in the generation transaction provides enough randomness
	# for the hash, so we can start checking proofs at zero.
	proof = 0

    while !valid_proof(last_proof, proof, last_hash)
        proof += 1
    end
    return proof
end

Base.length(bc::Blockchain) = length(bc.chain)

snowchain = Blockchain()


new_transaction!(snowchain, "Derik", "Andrew", 10)
print(snowchain)

include("server.jl")

end
