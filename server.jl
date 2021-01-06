using UUIDs: uuid4
using Genie, Genie.Router, Genie.Requests, Genie.Renderer.Json

# Generate a globally unique address for this node
node_id = replace(string(uuid4()), "-"=>"")

route("/mine") do
	(:message => "We'll mine a new Block") |> json
end

route("transactions/new", method=POST) do
	fields = jsonpayload()
	@show fields

	required = ["sender", "recipient", "amount"]
	if !(required ⊆ keys(fields))
		return (:error => "Missing fields" => setdiff(required, keys(fields))) |> json
	end

	# Create a new transaction
	index = new_transaction!(snowchain,
		fields["sender"], fields["recipient"], parse(Int, fields["amount"]))

	(:message => "Transaction will be added to Block $index") |> json
end

route("/chain") do
	Dict(:chain => snowchain.chain, :length => length(snowchain)) |> json
end

# Start web server at http://127.0.0.1:5000
up(5000)
