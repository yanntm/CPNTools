package org.cpntools.grader.model;

/**
 * @author michael
 */
public class StudentID implements Comparable<StudentID> {
	private final String id;

	/**
	 * @param id
	 */
	public StudentID(final String id) {
		this.id = id;
	}

	/**
	 * @return
	 */
	public String getId() {
		return id;
	}

	@Override
	public String toString() {
		return id;
	}
	
	@Override
	public int compareTo(StudentID o) {
		return getId().compareTo(o.getId());
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		StudentID other = (StudentID) obj;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;
		return true;
	}
}
