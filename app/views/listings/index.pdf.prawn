items = @listings.map do |listing|
  [
    listing.street_address,
    listing.neighborhood.try( :name ),
    listing.bed.try(:name),
    number_to_currency(listing.price),
    listing.available_date,
    listing.user.try(:name)
  ]
end
items.unshift ['Street address', 'Neighborhood', 'Beds', "Price", 'Available date', 'Agent']

pdf.table(items) do
  row(0).background_color = "DDDDDD"
end