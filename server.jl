using UUIDs: uuid4
using Genie, Genie.Router, Genie.Requests, Genie.Renderer.Json

# Generate a globally unique address for this node
const NODE_ID = replace(string(uuid4()), "-"=>"")

# Instatiate the blockchain
snowchain = Blockchain()

route("/mine") do
	(:message => "We'll mine a new block") |> json
	last_block = snowchain[end]
	last_proof = last_block.proof
	last_hash = shash(last_block)
	proof = proof_of_work(last_proof, last_hash)

	new_transaction!(snowchain, "", NODE_ID, REWARD)

	# Add the block to the chain
	block = new_block(proof, last_hash)

	response = Dict(
		:message => "New block mined",
		:index => block.index,
		:transactions => block.transactions,
		:proof => block.proof,
		:previous_hash => last_hash
	)
	return json(response, status=200)
end

route("transactions/new", method=POST) do
	required = ["sender", "recipient", "amount"]
	@show rawpayload()
	fields = jsonpayload()
	if fields == nothing
		return json(:error => "Format request as JSON object with keys " * join(required, ", "), status=400)
	end
	@show fields

	if !(required ⊆ keys(fields))
		return json(:error => "Missing keys" => setdiff(required, keys(fields)), status=400)
	end

	# Create a new transaction
	index = new_transaction!(snowchain, fields["sender"], fields["recipient"], fields["amount"])

	return json(:message => "Transaction will be added to block $index", status=201)
end

route("/chain") do
	Dict(:chain => snowchain.chain, :length => length(snowchain)) |> json
end

# Start web server at http://127.0.0.1:5000
up(5000)
