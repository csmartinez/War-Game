# War Card Game (Code Challenge)

## How to Run Locally (Mac)

1. **Open your terminal.**
2. **Navigate to the project directory**
3. **Run the game:**
   ```sh
   ruby war.rb
   ```
4. **Follow the prompts in the console** to enter the number of players (2 or 4) and play the game.

## Basic Rules of War

- The deck is evenly divided among all players.
- Each round, all active players play the top card of their hand.
- The player with the highest card wins all cards played that round.
- If there is a tie for the highest card, a "war" occurs:
  - Each tied player places three cards face down and one card face up.
  - The highest face-up card wins all cards in the pile.
  - If another tie occurs, the war repeats among tied players.
- Players are eliminated when they run out of cards.
- The last player with cards remaining wins the game.
