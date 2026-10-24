# The Stilled Bell — opening contract

This document locks the narrative assumptions used by the playable v0. It is a local episode design and does not claim to settle future campaign canon.

## Place and chronology

Bellfold is a small farming settlement on the Caemlyn road, west of Four Kings in Andor. Its founders left an oral charge to guard a ledger said to preserve an imperial land grant. The ledger is held by Mara, whose family has copied and repaired it for generations. The settlement has no verified proof of direct descent from Artur Hawkwing.

The episode opens at dawn on **24 Amadaine, 999 NE**, the day after Rand's revelation at Alcair Dal. This is an author-set fan-story date at the end of [*The Shadow Rising*'s chronology](https://www.encyclopaedia-wot.org/Wiki.jsp?page=Timeline); that chronology notes gaps and cannot precisely date every parallel event. Bellfold has heard only old, unverified reports of a Dragon claimant in Tear. News from Alcair Dal has not reached it. The episode does not replace, confirm, or contradict Rand's claim.

## Ledger and prophecy

The only surviving ledger is a patched vellum folio hidden inside an ordinary tax book. A note in a later hand says a village founder was entrusted with it during the Empire's collapse; who gave the order and why are lost. Its handwriting, material, and conflicting place names make its date disputed. The folio mixes plausible land records, missing years, and later marginal interpretation.

The opening fragment is copied from one damaged margin:

> When the still bell answers a hand untaught, stone shall refuse its weight. The old road will divide at the keeper's word. At the Last Battle, that hand shall tip the balance, but shall not name the victor.

Author-facing truth: the fragment is an authentic but incomplete prophecy. The witnessed awakening signals an unavoidable rupture in the world's order, and this protagonist will decisively influence the Last Battle. It does not identify the Dragon Reborn, choose a side, promise victory, or prescribe the protagonist's decision. The fragment's claimed tie to the ledger remains genuinely disputed inside the episode because the surviving copy cannot establish its own provenance.

## People and conflict

- **Edrin**, elected village speaker, wants a public imperial recognition that could protect the road and restore Bellfold's standing. He rejects a private witnessed copy because he fears the settlement will receive no recognition.
- **Mara**, keeper, values the ledger as an inheritance and fears a one-way transfer will erase the village's only evidence.
- **Tovin**, the protagonist's close friend, helped prepare their personal task. Tovin wants the protagonist's future to stay theirs and will react to the chosen account without becoming a combat companion.
- **Serah**, an itinerant Cairhienin archivist, carries a magistrate's sealed order. A border archive burned; she needs the ledger to reconstruct land grants before troops arrive. She is willing to negotiate, but the magistrate's order permits seizure after talks fail.
- **The guard** follows the magistrate's order. Edrin refuses a witnessed copy and demands a public pledge of village status. Serah does not order the guard to attack; the conflict escalates because her written authority allows seizure and the parties reject the available compromise.

The episode uses one enemy archetype. Combat starts with the protagonist's weapon. The involuntary Power burst occurs when Mara is threatened, is seen by the villagers, and does not establish what the prophecy means.

## Player setup and route

| Choice | Shared playable sequence | Contextual effect |
| --- | --- | --- |
| Raised by Mara's family | Repair and deliver the bell rope | The task is framed as a promise and family duty. |
| Family claims Hawkwing descent | Repair and deliver the bell rope | Edrin invokes the claimed heritage; the text does not treat descent as proven. |
| Prepare to leave | Same task, people, and location | Tovin connects the rope to the protagonist's travel preparations. |
| Care for someone here | Same task, people, and location | Tovin recalls Mara teaching the old repair knot. |
| Woman / man | Same combat and quest rules | Mara's reaction during the awakening changes in dialogue. |

Six beats: personal task → record request → attempted seizure → involuntary awakening → custody and testimony → immediate consequence. After the request, the player reads Serah's signed order and hears Edrin's and Mara's independent responses before returning to Serah. Both reject the available compromise; the order's seizure clause explains why the guard arrives.

## Outcome contract

| Custody | Testimony | Relationship and local response | Wider-world hook |
| --- | --- | --- | --- |
| Mara keeps the original | Admit it was uncontrolled channeling | Mara opens the map room and shares a copy; Tovin remains close; Edrin sends a witness with Serah. | Learn what is on the disputed map and leave before soldiers return. |
| Mara keeps the original | Stay silent | Map room stays locked; Tovin is unsettled; Serah leaves warning that soldiers may return. | Protect the village before the seizure order returns. |
| Serah receives the original | Admit it was uncontrolled channeling | The gate opens toward the magistrate's hearing; Mara gives the protagonist a copied page; Tovin trusts the honest account. | Bring the copy to the hearing and ask who ordered the seizure. |
| Serah receives the original | Stay silent | The gate still opens for the hearing; Mara withholds her copy; Tovin withdraws; witnesses still report the light. | Learn what Serah tells the magistrate before the village is labeled. |

The testimony changes trust and dialogue; it cannot change the witnessed event. Consequences are applied once per run. Defeat reloads the encounter while retaining the task and character selections; a new journey clears them.

## Runtime choices

Godot 4.7.2 standard build; macOS desktop is the first export target. The prototype uses keyboard/mouse, a follow camera with mouse orbit, typed GDScript, built-in primitives, in-memory session state, and a Godot-imported CSV translation catalog. No third-party asset licenses or external runtime dependencies are involved.
