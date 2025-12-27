module ApplicationHelper
  def account_color(account)
    # Generate a consistent color for each account based on its ID
    colors = [
      "#3b82f6", # blue
      "#10b981", # green
      "#f59e0b", # amber
      "#ef4444", # red
      "#8b5cf6", # purple
      "#ec4899", # pink
      "#06b6d4", # cyan
      "#f97316"  # orange
    ]
    colors[account.id % colors.length]
  end

  def email_initials(email_address)
    # Extract name or email and get initials
    if email_address.include?("<")
      # Format like "John Doe <john@example.com>"
      name = email_address.split("<").first.strip
    elsif email_address.include?("@")
      # Format like "john@example.com"
      name = email_address.split("@").first
    else
      name = email_address
    end

    # Get first 2 characters or first letter of first 2 words
    words = name.split(/[\s._-]/)
    if words.length >= 2
      "#{words[0][0]}#{words[1][0]}".upcase
    else
      name[0..1].upcase
    end
  end

  def avatar_color(email_address)
    # Generate consistent color based on email
    colors = [
      "#0078d4", "#d83b01", "#107c10", "#5c2d91",
      "#008272", "#00188f", "#e3008c", "#00bcf2"
    ]
    hash = email_address.sum
    colors[hash % colors.length]
  end

  def next_page_path(collection)
    return nil unless collection.next_page
    url_for(request.params.merge(page: collection.next_page, only_path: true))
  end
end
