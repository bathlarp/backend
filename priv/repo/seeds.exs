# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     BathLARP.Repo.insert!(%BathLARP.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

BathLARP.Repo.insert!(
  %BathLARP.SiteConfiguration.Pronouns{
    id: "bd932600-a091-42d6-a4d3-4399a1219b17",
    subjective_personal: "he",
    objective_personal: "him",
    possessive: "his",
    possessive_determiner: "his",
    reflexive: "himself"
  },
  on_conflict: :replace_all,
  conflict_target: :id
)

BathLARP.Repo.insert!(
  %BathLARP.SiteConfiguration.Pronouns{
    id: "f000fd12-c2fa-44cb-ad24-af8771e5b866",
    subjective_personal: "she",
    objective_personal: "her",
    possessive: "her",
    possessive_determiner: "hers",
    reflexive: "herself"
  },
  on_conflict: :replace_all,
  conflict_target: :id
)

BathLARP.Repo.insert!(
  %BathLARP.SiteConfiguration.Pronouns{
    id: "39057cf0-a98b-4dd4-a77c-8f0193783ad3",
    subjective_personal: "they",
    objective_personal: "them",
    possessive: "their",
    possessive_determiner: "theirs",
    reflexive: "themself"
  },
  on_conflict: :replace_all,
  conflict_target: :id
)
