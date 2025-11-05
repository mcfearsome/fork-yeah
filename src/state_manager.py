#!/usr/bin/env python3

"""
state_manager.py
Manages conversation state checkpointing and restoration for fork-yeah
"""

import json
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional
import hashlib


class StateManager:
    """Manages conversation state for fork branching"""

    def __init__(self, data_dir: str = None):
        """Initialize state manager with data directory"""
        self.data_dir = Path(data_dir or os.path.expanduser("~/.claude-code/forks"))
        self.data_dir.mkdir(parents=True, exist_ok=True)

    def generate_fork_id(self, parent_id: Optional[str] = None) -> str:
        """Generate unique fork ID"""
        timestamp = datetime.now().isoformat()
        base = f"{parent_id or 'root'}-{timestamp}"
        hash_obj = hashlib.sha256(base.encode())
        return hash_obj.hexdigest()[:12]

    def create_checkpoint(
        self,
        fork_id: str,
        parent_id: Optional[str] = None,
        conversation_history: List[Dict] = None,
        context: Dict = None,
        metadata: Dict = None,
    ) -> Dict:
        """Create a conversation checkpoint"""

        checkpoint = {
            "fork_id": fork_id,
            "parent_id": parent_id,
            "timestamp": datetime.now().isoformat(),
            "conversation_history": conversation_history or [],
            "context": context or {},
            "metadata": metadata or {},
            "version": "0.1.0",
        }

        # Ensure fork directory exists
        fork_dir = self.data_dir / fork_id
        fork_dir.mkdir(parents=True, exist_ok=True)

        # Save checkpoint
        checkpoint_file = fork_dir / "checkpoint.json"
        with open(checkpoint_file, "w") as f:
            json.dump(checkpoint, f, indent=2)

        # Create metadata file
        self._save_metadata(fork_id, checkpoint)

        return checkpoint

    def load_checkpoint(self, fork_id: str) -> Optional[Dict]:
        """Load a conversation checkpoint"""
        checkpoint_file = self.data_dir / fork_id / "checkpoint.json"

        if not checkpoint_file.exists():
            return None

        with open(checkpoint_file, "r") as f:
            return json.load(f)

    def update_checkpoint(self, fork_id: str, updates: Dict) -> bool:
        """Update an existing checkpoint"""
        checkpoint = self.load_checkpoint(fork_id)

        if not checkpoint:
            return False

        # Merge updates
        checkpoint.update(updates)
        checkpoint["last_modified"] = datetime.now().isoformat()

        # Save updated checkpoint
        checkpoint_file = self.data_dir / fork_id / "checkpoint.json"
        with open(checkpoint_file, "w") as f:
            json.dump(checkpoint, f, indent=2)

        return True

    def _save_metadata(self, fork_id: str, checkpoint: Dict):
        """Save fork metadata for quick lookups"""
        metadata = {
            "fork_id": fork_id,
            "parent_id": checkpoint.get("parent_id"),
            "created_at": checkpoint["timestamp"],
            "last_modified": checkpoint["timestamp"],
            "status": "active",
        }

        metadata_file = self.data_dir / fork_id / "metadata.json"
        with open(metadata_file, "w") as f:
            json.dump(metadata, f, indent=2)

    def get_metadata(self, fork_id: str) -> Optional[Dict]:
        """Get fork metadata"""
        metadata_file = self.data_dir / fork_id / "metadata.json"

        if not metadata_file.exists():
            return None

        with open(metadata_file, "r") as f:
            return json.load(f)

    def list_forks(self) -> List[Dict]:
        """List all fork checkpoints"""
        forks = []

        for fork_dir in self.data_dir.iterdir():
            if fork_dir.is_dir():
                metadata = self.get_metadata(fork_dir.name)
                if metadata:
                    forks.append(metadata)

        # Sort by creation time
        forks.sort(key=lambda x: x.get("created_at", ""), reverse=True)

        return forks

    def get_fork_tree(self) -> Dict:
        """Build fork tree structure"""
        forks = self.list_forks()
        tree = {"root": {"children": [], "metadata": {}}}

        # Build a mapping from fork_id to tree node
        node_map = {}
        for fork in forks:
            node_map[fork["fork_id"]] = {
                "fork_id": fork["fork_id"],
                "children": [],
                "metadata": fork
            }

        # Attach nodes to their parents, or to root if no parent
        for fork in forks:
            node = node_map[fork["fork_id"]]
            parent_id = fork.get("parent_id")
            if not parent_id:
                tree["root"]["children"].append(node)
            else:
                parent_node = node_map.get(parent_id)
                if parent_node:
                    parent_node["children"].append(node)

        return tree

    def delete_fork(self, fork_id: str) -> bool:
        """Delete a fork checkpoint and its data"""
        fork_dir = self.data_dir / fork_id

        if not fork_dir.exists():
            return False

        # Delete directory and all contents
        import shutil

        shutil.rmtree(fork_dir)

        return True

    def export_checkpoint(self, fork_id: str, output_path: str) -> bool:
        """Export checkpoint to file"""
        checkpoint = self.load_checkpoint(fork_id)

        if not checkpoint:
            return False

        with open(output_path, "w") as f:
            json.dump(checkpoint, f, indent=2)

        return True

    def import_checkpoint(self, input_path: str, fork_id: Optional[str] = None) -> Optional[str]:
        """Import checkpoint from file"""
        with open(input_path, "r") as f:
            checkpoint = json.load(f)

        # Generate new fork ID if not provided
        if not fork_id:
            fork_id = self.generate_fork_id(checkpoint.get("parent_id"))

        checkpoint["fork_id"] = fork_id

        # Save checkpoint
        fork_dir = self.data_dir / fork_id
        fork_dir.mkdir(parents=True, exist_ok=True)

        checkpoint_file = fork_dir / "checkpoint.json"
        with open(checkpoint_file, "w") as f:
            json.dump(checkpoint, f, indent=2)

        return fork_id


def main():
    """CLI interface for state manager"""
    if len(sys.argv) < 2:
        print("Usage: state_manager.py <command> [args...]")
        print("Commands:")
        print("  create <fork_id> [parent_id]")
        print("  load <fork_id>")
        print("  list")
        print("  delete <fork_id>")
        print("  export <fork_id> <output_file>")
        print("  import <input_file> [fork_id]")
        sys.exit(1)

    command = sys.argv[1]
    manager = StateManager()

    if command == "create":
        if len(sys.argv) < 3:
            print("Error: fork_id required")
            sys.exit(1)

        fork_id = sys.argv[2]
        parent_id = sys.argv[3] if len(sys.argv) > 3 else None

        checkpoint = manager.create_checkpoint(
            fork_id=fork_id,
            parent_id=parent_id,
            conversation_history=[],
            context={},
            metadata={"created_via": "cli"},
        )

        print(json.dumps(checkpoint, indent=2))

    elif command == "load":
        if len(sys.argv) < 3:
            print("Error: fork_id required")
            sys.exit(1)

        fork_id = sys.argv[2]
        checkpoint = manager.load_checkpoint(fork_id)

        if checkpoint:
            print(json.dumps(checkpoint, indent=2))
        else:
            print(f"Error: Checkpoint not found for fork {fork_id}")
            sys.exit(1)

    elif command == "list":
        forks = manager.list_forks()
        print(json.dumps(forks, indent=2))

    elif command == "delete":
        if len(sys.argv) < 3:
            print("Error: fork_id required")
            sys.exit(1)

        fork_id = sys.argv[2]
        success = manager.delete_fork(fork_id)

        if success:
            print(f"Deleted fork: {fork_id}")
        else:
            print(f"Error: Fork not found: {fork_id}")
            sys.exit(1)

    elif command == "export":
        if len(sys.argv) < 4:
            print("Error: fork_id and output_file required")
            sys.exit(1)

        fork_id = sys.argv[2]
        output_file = sys.argv[3]

        success = manager.export_checkpoint(fork_id, output_file)

        if success:
            print(f"Exported checkpoint to: {output_file}")
        else:
            print(f"Error: Failed to export fork: {fork_id}")
            sys.exit(1)

    elif command == "import":
        if len(sys.argv) < 3:
            print("Error: input_file required")
            sys.exit(1)

        input_file = sys.argv[2]
        fork_id = sys.argv[3] if len(sys.argv) > 3 else None

        new_fork_id = manager.import_checkpoint(input_file, fork_id)

        if new_fork_id:
            print(f"Imported checkpoint as fork: {new_fork_id}")
        else:
            print("Error: Failed to import checkpoint")
            sys.exit(1)

    else:
        print(f"Error: Unknown command: {command}")
        sys.exit(1)


if __name__ == "__main__":
    main()
