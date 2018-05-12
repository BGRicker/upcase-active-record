class Person < ActiveRecord::Base
  belongs_to :role
end

class Role < ActiveRecord::Base
  has_many :people
end

Person.all.joins(:role)
SELECT "people".*
FROM "people"
INNER JOIN "roles"
  ON "roles"."id" = "people"."role_id";

# anything you send to ActiveRecord it's going to have to build and send back
# don't create extra stuff from queries that you don't need for AR to compute

Person.all.joins(:role).where(roles: {billable: true})
SELECT "people".*
FROM "people"
INNER JOIN "roles"
  ON "roles"."id" = "people"."role_id"
WHERE "roles"."billable" = 't';

# returns only people with roles where billable true
# 't' here unique to postgres, would be different on another db engine

Role.where(billable: true)
SELECT "roles".*
FROM "roles"
WHERE "roles"."billable" = 't';

# returns only roles where billable is true

class Role < ActiveRecord::Base
  has_many :people

  def self.billable
    where(billable: true)
  end
end

Role.billable
SELECT "roles".*
FROM "roles"
WHERE "roles"."billable" = 't';

#creates method for common query

Person.all.merge(Role.billable)
SELECT "people".*
FROM "people"
WHERE "roles"."billable" = 't';

# merge on ActiveRecord relation object built from role model
# generates SQL for finding all people, but threw on where clause from role
# postgres doesn't know right here what roles we're talking about

Person.joins(:role).merge(Role.billable)
SELECT "people".*
FROM "people"
INNER JOIN "roles"
  ON "roles"."id" = "people"."role_id"
WHERE "roles"."billable" = 't';

# join in role association, then what to filter on roles table once it's joined

class Person < ActiveRecord::Base
  belongs_to :role

  def self.billable
    joins(:role).merge(Role.billable)
  end
end

# now call Person.billable to get all billable people
