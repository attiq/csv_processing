require 'csv'
require 'rubygems'
$LOGGER = Logger.new('log/csv.log', 'daily')

class User < ActiveRecord::Base

  validates :email, uniqueness: true, allow_blank: true

  def self.process_csv
    $LOGGER.info "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    $LOGGER.info "[#{Time.now}] Start CSV Processing."
    begin
      response = []
      CSV.parse(File.read(File.join(File.expand_path('../csv_processing/doc'), 'people.csv')), :headers => true).each do |row|

        params = {name: row['Name'], email: row['Email Address'], phone: row['Telephone Number'], website: row['Website']}

        # Rows without a name or email address should not be imported
        next if params[:name].blank? && params[:email].blank?

        # check if user is already existes
        user = User.where('name = ? OR email = ? ', params[:name], params[:email])

        # if user already exists update the data otherwise will create a new user
        if user.present?
          if user.update_attributes(params)
            response << "#{user.name}:#{user.email} was succefully updated."
          else
            response << user.errors.full_messages.join(", ")
          end
        else
          user = User.create(params)
          if user.save
            response << "#{user.name}:#{user.email} was succefully created."
          else
            response << user.errors.full_messages.join(", ")
          end
        end
      end
      $LOGGER.info "[#{Time.now}] End CSV Processing."
      return response
    rescue => e
      $LOGGER.error "[#{Time.now}] Error processing Abandon Basket Emails Service: #{e.inspect}"
    end
  end

end
