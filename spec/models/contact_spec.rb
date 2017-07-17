require 'rails_helper'

describe Contact do
  # 姓と名とメールがあれば有効な状態であること
  it "is valid with a firstname, lastname and email" do
    contact = Contact.new(
      firstname: 'Shoken',
      lastname: 'Fujisaki',
      email: 'shoken@example.com')
    expect(contact).to be_valid
  end
  # 名がなければ無効な状態であること
  it "is invalid without a firstname" do
    contact = Contact.new(firstname: nil)
    contact.valid?
    expect(contact.errors[:firstname]).to include("can't be blank")
  end

  # 姓がなければ無効な状態であること
  it "is invalid without a lastname" do
    contact = Contact.new(lastname: nil)
    contact.valid?
    expect(contact.errors[:lastname]).to include("can't be blank")
  end
  # メールアドレスがなければ無効な状態であること
  it "is invalid without an email address" do
    contact = Contact.new(email: nil)
    contact.valid?
    expect(contact.errors[:email]).to include("can't be blank")
  end
  # 重複したメールアドレスなら無効な状態であること
  it "is invalid with a duplicate email address" do
    Contact.create(
      firstname: 'joe', lastname: 'tester',
      email: 'tester@example.com'
    )
    contact = Contact.new(
      firstname: 'jane', lastname: 'tester',
      email: 'tester@example.com'
    )
    contact.valid?
    expect(contact.errors[:email]).to include("has already been taken")
  end
  # 連絡先のフルネームを文字列として返すこと
  it "returns a contact's full name as a string" do
    contact = Contact.new(firstname: 'John', lastname: 'Doe',
                          email: 'johndoe@example.com')
    expect(contact.name).to eq 'John Doe'
  end

  it "has a valid factory" do
    expect(build(:contact)).to be_valid
  end

  it { is_expected.to validate_presence_of :firstname }
  it { is_expected.to validate_presence_of :lastname }
  it { is_expected.to validate_presence_of :email }
  it { is_expected.to validate_uniqueness_of(:email) }

  it "returns a contact's full name as a string" do
    contact = build_stubbed(:contact,
      firstname: 'Jane',
      lastname: 'Smith'
    )
    expect(contact.name).to eq 'Jane Smith'
  end

  it "has three phone numbers" do
    expect(create(:contact).phones.count).to eq 3
  end

  describe "filter last name by letter" do
    before :each do
      @smith = create(:contact,
        firstname: 'John',
        lastname: 'Smith',
        email: 'jsmith@example.com'
      )
      @jones = create(:contact,
        firstname: 'Tim',
        lastname: 'Jones',
        email: 'tjones@example.com'
      )
      @johnson = create(:contact,
        firstname: 'John',
        lastname: 'Johnson',
        email: 'jjohnson@example.com'
      )
    end

    context "with matching letters" do
      it "returns a sorted array of results that match" do
        expect(Contact.by_letter("J")).to eq [@johnson, @jones]
      end
    end

    context "with non-matching letters" do
      it "omits results that do not match" do
        expect(Contact.by_letter("J")).not_to include @smith
      end
    end
  end
end
