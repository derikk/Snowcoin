# Blockchain.jl copyright © 2020 Derik Kauffman
# Based on https://hackernoon.com/learn-blockchains-by-building-one-117428612f46
# Original code copyright © 2017 Daniel van Flymen
# Licensed under the MIT license.

module Snowcoin

import SHA, Dates

struct Transaction
	sender
	recipient
	amount::Real
end

struct Block
	index::Int
	timestamp::Dates.DateTime
	transactions::Array{Transaction}
	proof
	previous_hash
end

mutable struct Blockchain
	chain::Array{Block}
	pending_transactions::Array{Transaction}
end

# Create the genesis block
Blockchain() = (bc = Blockchain([], []); new_block(bc, 0, 0); return bc)

"Create a new block and add it to the chain."
function new_block(bc::Blockchain, proof, previous_hash)
	block = Block(length(bc.chain) + 1,
	              Dates.now(Dates.UTC),
	              bc.pending_transactions,
	              proof,
	              previous_hash)

	bc.pending_transactions = []

	push!(bc.chain, block)
	return block
end
new_block(bc::Blockchain, proof) = new_block(bc, proof, hash_block(bc.chain[end]))

"Create a new transaction to go into the next mined block."
function new_transaction(bc::Blockchain, sender, recepient, amount::Real)
	transaction = Transaction(sender, recepient, amount)
	push!(bc.pending_transactions, transaction)

	return bc.chain[end].index + 1
end

"Hash a block."
function hash_block(block::Block)
	return SHA.sha256(string(block))
end

end
