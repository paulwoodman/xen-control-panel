require 'bundler/setup'
require 'mongoid'
ENV['MONGOID_ENV'] = "development"
Mongoid.load!("./mongoid.yml")

class User
  include Mongoid::Document
  belongs_to :rank
  embeds_many :vms

  field :username, type: String
  index({ username: 1 })
  index "vms.hostname" => 1

  validates_uniqueness_of :username
  validates_presence_of :username
  validates :username, uniqueness: true, presence: true
end

class Vm
  include Mongoid::Document
  embedded_in :user

  field :ram, type: Integer
  field :swap, type: Integer
  field :hdd, type: Integer
  field :cpus, type: Integer
  field :ip, type: String
  field :hostname, type: String
  field :os, type: String
  field :price, type: Float

  validates_uniqueness_of :hostname, :ip
  validates_presence_of :ram, :swap, :hdd, :cpus, :ip, :hostname, :os
end

class Rank
  include Mongoid::Document
  has_many :users

  field :name, type: String
  field :create_vms, type: Boolean
  field :free_upgrades, type: Boolean
end

class PasswordGenerator
  SYLLABLES = %w(ba be bi bo bu by da de di do du dy fe fi fo fu fy ga ge gi
    go gu gy ha he hi ho hu hy ja je ji jo ju jy ka ke ko ku ky la le li lo
    lu ly ma me mi mo mu my na ne ni no nu ny pa pe pi po pu py ra re ri ro
    ru ry sa se si so su sy ta te ti to tu ty va ve vi vo vu vy bra bre bri
    bro bru bry dra dre dri dro dru dry fra fre fri fro fru fry gra gre gri
    gro gru gry pra pre pri pro pru pry sta ste sti sto stu sty tra tre er
    ed in ex al en an ad or at ca ap el ci an et it ob of af au cy im op co
    up ing con ter com per ble der cal man est for mer col ful get low son
    tle day pen pre ten tor ver ber can ple fer gen den mag sub sur men min
    out tal but cit cle cov dif ern eve hap ket nal sup ted tem tin tro tro)

  def initialize
    srand
  end

  def generate(length)
    result = ''
    while result.length < length
      syl = SYLLABLES[rand(SYLLABLES.length)]
      result += syl
    end
    result = result[0,length]
    # Stick in a digit
    dpos = rand(length)
    result[dpos,1] = rand(9).to_s
    # Make a letter capitalized
    cpos = rand(length)
    result[cpos,1] = result[cpos,1].swapcase
    return result
  end
end
