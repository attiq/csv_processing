require 'csv'
require 'rubygems'
$LOGGER = Logger.new('log/csv.log', 'daily')

class User < ActiveRecord::Base

  validates :name, presence: true
  validates :email, presence: true
  validates :email, uniqueness: true

  def self.process_csv
    $LOGGER.info "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    $LOGGER.info "[#{Time.now}] Start CSV Processing."
    begin
      response = []
      CSV.parse(File.read(File.join(File.expand_path('../csv_processing/doc'), 'people.csv')), :headers => true).each do |row|

        params = {name: row['Name'], email: row['Email Address'], phone: row['Telephone Number'], website: row['Website']}

        # Rows without a name or email address should not be imported
        next if params[:name].blank? || params[:email].blank?

        # if user already exists update the data otherwise will create a new user
        user = User.where(email: params[:email]).first_or_initialize

        if user.update_attributes(params)
          response << "#{user.name}:#{user.email} was succefully processed."
        else
          response << user.errors.full_messages.join(", ")
        end
      end
      $LOGGER.info "[#{Time.now}] End CSV Processing."
      return response
    rescue => e
      $LOGGER.error "[#{Time.now}] Error processing Abandon Basket Emails Service: #{e.inspect}"
    end
  end

end
