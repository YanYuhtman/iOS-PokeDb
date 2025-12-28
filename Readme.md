# PokeDb

This is a sample project.

PokeDb is a modern and interactive iOS application built with SwiftUI, designed to be your personal Pokedex. It allows users to browse a comprehensive list of Pokémon, view detailed information for each, manage favorites, and visualize their stats with engaging charts.

## Features

-   **Comprehensive Pokémon List:** Browse through a detailed list of various Pokémon.
-   **Search and Filter:** Easily find Pokémon by name using the search bar, and filter the list to show only your favorited Pokémon.
-   **Favorite Management:** Mark and unmark Pokémon as favorites for quick access.
-   **Detailed Pokémon Profiles:** Each Pokémon entry provides in-depth information, including:
    -   Name and Image
    -   Elemental Types
    -   Interactive Stat Charts (HP, Attack, Defense, Special Attack, Special Defense, Speed)
    -   Dynamic background based on Pokémon types.
-   **Local Persistence:** All your favorited Pokémon and data are stored locally using SwiftData, ensuring a seamless experience.
-   **Data Update Mechanism:** Easily update the Pokémon data within the app to ensure you have the latest information.

## Technologies Used

-   **SwiftUI:** For a declarative and modern user interface.
-   **Core Data:** Apple's new persistence framework for efficient local data storage. (For Swift Data migration see `migration/SwiftData` branch)
-   **Charts Framework:** To provide rich and interactive visualizations of Pokémon stats.
-   **Swift:** The powerful and intuitive programming language for iOS development.

## Data Model

The core data representation in PokeDb is the `PokeItem` model, managed by SwiftData. Each `PokeItem` object encapsulates the following attributes of a Pokémon:

-   **`id`**: Unique identifier for the Pokémon (Int16).
-   **`name`**: The name of the Pokémon (String, e.g., "Pikachu").
-   **`types`**: An array of strings representing the Pokémon's elemental types (e.g., `["Electric"]` or `["Grass", "Poison"]`).
-   **`favorite`**: A boolean indicating if the Pokémon has been marked as a favorite.
-   **`hp`**: Hit Points (Int16).
-   **`attack`**: Attack stat (Int16).
-   **`defence`**: Defense stat (Int16).
-   **`specialAttack`**: Special Attack stat (Int16).
-   **`specialDefense`**: Special Defense stat (Int16).
-   **`speed`**: Speed stat (Int16).
-   **`spriteURL`**: URL for the Pokémon's main sprite image.
-   **`spriteRaw`**: Raw data for the Pokémon's main sprite image (for local storage).
-   **`shinyURL`**: URL for the Pokémon's shiny sprite image.
-   **`shinyRaw`**: Raw data for the Pokémon's shiny sprite image (for local storage).

## Installation and Setup

To get a copy of this project up and running on your local machine for development and testing purposes, follow these steps:

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/yourusername/PokeDb.git # Replace with actual repo URL
    ```
2.  **Open in Xcode:**
    Navigate to the cloned directory and open the `PokeDb.xcodeproj` file using Xcode.
3.  **Build and Run:**
    Select your desired target device or simulator and run the application.

## Usage

-   **Browse:** Upon launching the app, you'll see a list of Pokémon.
-   **Search:** Use the search bar at the top to filter Pokémon by name.
-   **Favorites:** Tap the star icon in the toolbar to toggle between all Pokémon and your favorites. You can also swipe left on a Pokémon in the list or use the star icon on the detail page to mark it as a favorite.
-   **Details:** Tap on any Pokémon in the list to view its detailed profile, including stats and types.
-   **Update Data:** If the list is empty or you wish to refresh the data, use the "Update" button (sparkles icon) in the toolbar.

