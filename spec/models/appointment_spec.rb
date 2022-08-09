RSpec.describe Appointment do

  it "creates an appointment" do
    expect { FactoryBot.create(:appointment) }.to change(Appointment, :count).by(1)
  end
end
