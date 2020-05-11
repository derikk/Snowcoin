# Blockchain.jl copyright © 2020 Derik Kauffman
# Based on https://hackernoon.com/learn-blockchains-by-building-one-117428612f46
# Original code copyright © 2017 Daniel van Flymen
# Licensed under the MIT license.

module Snowcoin

struct Transaction
	sender
	recipient
	amount::Real
end

struct Block
	index::Integer
	timestamp
	transactions::Array{Transaction}
	proof
	previoushash
end

mutable struct Blockchain
	lastblock::Block
end


"Create a new block and add it to the chain."
function newblock(blockchain::Blockchain)
end

"Add a new transaction to the list of transactions."
function newtransaction(blockchain::Blockchain)
end

"Hash a block."
function hashblock(block::Block)
end

end
